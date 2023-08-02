# Importing required modules
import PyPDF2

def extract_pages(source_pdf, start_page, end_page, output_pdf):
    # Creating a PDF file reader object
    source = PyPDF2.PdfReader(source_pdf)
    
    # Creating a PDF writer object
    output = PyPDF2.PdfWriter()
    
    # Copying the pages from source PDF to output PDF
    for i in range(start_page-1, end_page):
        output.add_page(source.pages[i])
    
    # Writing output PDF
    with open(output_pdf, "wb") as output_pdf_file:
        output.write(output_pdf_file)

# Provide the source PDF, the start and end pages to extract, and the output PDF filename
extract_pages("wei_series_md.pdf", 17, 20, "paper_major_changes.pdf")
