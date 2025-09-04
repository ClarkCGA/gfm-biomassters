import matplotlib.pyplot as plt
import numpy as np
import PIL.Image
import numpy
from pathlib import Path
import glob
from sklearn.metrics import r2_score

def get_all_values(directory):
    tensor_list = list(directory.glob('*.tif'))
    tensor_list.sort()
    arrays = [np.asarray(PIL.Image.open(tensor)).flatten() for tensor in tensor_list]
    return np.concatenate(arrays)


def RMSE(target,pred):
    return np.sqrt(np.mean((target-pred)**2))

def plot_predictions_with_baseline(input_dir, target_dir, baseline_dir, pred_dir):
    fig, axes = plt.subplots(4, 4, figsize=(12, 12), layout="constrained")
    a = 0
    for i in [101,102,103,104]:
        rgb = numpy.asarray(PIL.Image.open(input_dir / f'test_input_{i}.tif'))
        target = numpy.asarray(PIL.Image.open(target_dir / f'test_target_{i}.tif'))
        baseline_output = numpy.asarray(PIL.Image.open(baseline_dir / f'test_output_{i}.tif'))
        prithvi_output = numpy.asarray(PIL.Image.open(pred_dir / 'predictions' / f'test_output_{i}.tif'))

        prithvi_rmse = RMSE(prithvi_output, target)
        baseline_rmse = RMSE(baseline_output, target)
        
        axes[a, 0].imshow(rgb)
        axes[a, 0].set_title(f'S2 Input RGB')
        axes[a, 0].axis('off')
                             
        axes[a, 1].imshow(target, vmin=0, vmax=300)
        axes[a, 1].set_title(f'AGB Target')
        axes[a, 1].axis('off')
        
        axes[a, 2].imshow(baseline_output,vmin=0,vmax=300)
        axes[a, 2].set_title(f'Baseline Predction: RMSE {"%.2f" % baseline_rmse}')
        axes[a, 2].axis('off')
        
        im = axes[a, 3].imshow(prithvi_output, vmin=0, vmax=300)
        axes[a, 3].set_title(f'Prithvi Prediction: RMSE {"%.2f" % prithvi_rmse}')
        axes[a, 3].axis('off')

        a+=1
        
    fig.colorbar(im, ax=axes[:, 3], location='right', shrink=1.0)

    plt.savefig(pred_dir / 'map_comparison.png')

def plot_prediction_histograms(target_dir, baseline_dir, pred_dir):

    targets = get_all_values(target_dir)
    baseline_values = get_all_values(baseline_dir)
    pred_values = get_all_values(pred_dir / 'predictions')
    
    title1 = "Prithvi-EO-2.0-300M Predicted vs Observed AGB"
    title2 = "Baseline Predicted vs Observed AGB"
    
    for predictions, title in zip([pred_values, baseline_values], [title1, title2]):
        H, xedges, yedges = np.histogram2d(
            targets, predictions, 
            range=[[0, 800], [0, 800]], 
            bins=(160, 160)
        )
        
        # Set bins with no values to NaN
        #H = np.where(H == 0, np.nan, H)
        plt.figure(figsize=(8, 6))
        H_log = np.log(H)  # Use log1p to avoid log(0)
        
        z = np.polyfit(targets, predictions, 1)  # Linear fit (degree 1)
        p = np.poly1d(z)
        
        # Define x range for trendline based on the range of sampled targets
        x = np.linspace(0, 800, 100)
        
        # Calculate R^2 value
        predicted_values = p(targets)
        r2 = r2_score(predictions, predicted_values)
        
        
        # Plot the histogram using pcolormesh
        plt.figure(figsize=(8, 6))
        X, Y = np.meshgrid(xedges, yedges)
        plt.pcolormesh(X, Y, H_log.T, cmap='viridis', vmin=0, vmax=16)  # Transpose H to align correctly
        
        equation_text = f"y = {z[0]:.2f}x + {z[1]:.2f}\n$R^2$ = {r2:.3f}"
        #plt.text(0.05, 0.95, equation_text, transform=plt.gca().transAxes, fontsize=12,
        #         verticalalignment='top', bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white"))
        plt.plot(x, p(x), "r--", label = equation_text)
        # Add trendline equation and R^2 value as text
        
        plt.plot([0,800], [0,800], 'k--', label = "y = x")
        plt.legend()

        #vmax=np.percentile(H_log[~np.isnan(H_log)], 99)
        # Labels and title
        plt.xlabel("Observed AGB")
        plt.ylabel("Predicted AGB")
        plt.colorbar(label='Log(Frequency)')
        plt.title(title)
        plt.savefig(pred_dir / f'{title.split()[0]}.png')

baseline_root = Path('/baseline/test/')
input_dir = baseline_root / 'inputs'
target_dir = baseline_root / 'targets'
baseline_dir = baseline_root / 'outputs'
pred_root = Path('/output/paper_experiments')
pred_dir = pred_root / 's2_s1_12_step'
print('plotting predictions...')
plot_predictions_with_baseline(input_dir, target_dir, baseline_dir, pred_dir)
print('plotting histograms...')
plot_prediction_histograms(target_dir, baseline_dir, pred_dir)
