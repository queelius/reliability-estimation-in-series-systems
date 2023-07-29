import os
from pdf2image import convert_from_path

def convert_pdf_to_png(pdf_file_path, output_folder):
    images = convert_from_path(pdf_file_path)

    for page_num, image in enumerate(images, start=1):
        image_file_path = os.path.join(output_folder, f'{os.path.splitext(os.path.basename(pdf_file_path))[0]}_{page_num}.png')
        image.save(image_file_path, 'PNG')

def batch_convert_pdf_to_png(input_folder, output_folder):
    os.makedirs(output_folder, exist_ok=True)
    for root, _, files in os.walk(input_folder):
        for file_name in files:
            if file_name.lower().endswith('.pdf'):
                pdf_file_path = os.path.join(root, file_name)
                convert_pdf_to_png(pdf_file_path, output_folder)

if __name__ == "__main__":
    input_folder = "pdfs"
    output_folder = "pngs"
    batch_convert_pdf_to_png(input_folder, output_folder)
