#!/usr/bin/env python3

# Importing required libraries
from PIL import Image
import numpy as np
# Python code to turn the downsample function into a command-line tool
from argparse import ArgumentParser


def downsample_image(image_path, scale_factor):
    """
    Downsamples an image by a given factor using PIL.

    Parameters:
    - image_path (str): Path to the input image file.
    - scale_factor (int): Factor by which to downsample the image.

    Returns:
    - img_downsampled (PIL.Image): Downsampled image.
    """
    
    # Open the image using PIL
    img = Image.open(image_path)
    
    # Convert the image to a numpy array
    img_array = np.array(img)
    
    # Get the shape of the image
    height, width, _ = img_array.shape
    
    # Calculate new dimensions, making sure they are divisible by the scale factor
    new_height = (height // scale_factor) * scale_factor
    new_width = (width // scale_factor) * scale_factor
    
    # Crop the image if necessary to make dimensions divisible by scale factor
    if new_height != height or new_width != width:
        img_array = img_array[:new_height, :new_width]
    
    # Reshape and average the pixel values to downsample the image
    img_downsampled = img_array.reshape(new_height // scale_factor, scale_factor, 
                                        new_width // scale_factor, scale_factor, -1).mean(axis=(1, 3)).astype(np.uint8)
    
    # Convert the downsampled numpy array back to a PIL image
    img_downsampled = Image.fromarray(img_downsampled)
    
    return img_downsampled


def main():
    # Initialize argument parser
    parser = ArgumentParser(description="Downsample an image by a given scale factor.")
    parser.add_argument("input_path", help="Path to the input image file.")
    parser.add_argument("output_path", help="Path to save the downsampled output image.")
    parser.add_argument("scale_factor", type=int, help="Factor by which to downsample the image.")
    
    # Parse arguments
    args = parser.parse_args()
    
    # Perform downsampling
    downsampled_img = downsample_image(args.input_path, args.scale_factor)
    
    # Save the downsampled image
    downsampled_img.save(args.output_path)

# This allows the script to be run from the command line
if __name__ == "__main__":
    main()

# Note: The code is not run here due to lack of access to the file system. You can run it on your local machine.
