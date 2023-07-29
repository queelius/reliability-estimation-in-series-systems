import os
import PyPDF2
from PIL import Image

def convert_pdf_to_png(pdf_file_path, output_folder):
    with open(pdf_file_path, 'rb') as pdf_file:
        pdf_reader = PyPDF2.PdfFileReader(pdf_file)
        num_pages = pdf_reader.getNumPages()

        for page_num in range(num_pages):
            pdf_page = pdf_reader.getPage(page_num)
            image = pdf_page.extractText()  # Modify this line to extract images from PDF (if available)
            
            image_file_path = os.path.join(output_folder, f'page_{page_num + 1}.png')
            image.save(image_file_path, 'PNG')

if __name__ == "__main__":
    pdf_file_path = "example.pdf"
    output_folder = "output_images"
    os.makedirs(output_folder, exist_ok=True)
    convert_pdf_to_png(pdf_file_path, output_folder)
