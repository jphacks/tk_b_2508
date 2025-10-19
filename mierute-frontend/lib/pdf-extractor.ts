export async function extractTextFromPDF(file: File): Promise<string> {
  // Ensure we're on the client side
  if (typeof window === 'undefined') {
    throw new Error('PDF extraction can only be done on the client side');
  }

  try {
    // Dynamic import to avoid server-side execution
    const pdfjsLib = await import('pdfjs-dist');

    // Set up PDF.js worker from public directory
    pdfjsLib.GlobalWorkerOptions.workerSrc = '/pdf.worker.min.mjs';
    // Read file as ArrayBuffer
    const arrayBuffer = await file.arrayBuffer();

    // Load the PDF document
    const loadingTask = pdfjsLib.getDocument({ data: arrayBuffer });
    const pdf = await loadingTask.promise;

    let fullText = '';

    // Extract text from each page
    for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
      const page = await pdf.getPage(pageNum);
      const textContent = await page.getTextContent();

      // Concatenate text items
      const pageText = textContent.items
        .map((item) => {
          // Type guard: check if item has 'str' property (TextItem)
          if ('str' in item) {
            return item.str;
          }
          return '';
        })
        .join(' ');

      fullText += pageText + '\n';
    }

    return fullText.trim();
  } catch (error) {
    console.error('PDF extraction error:', error);
    throw new Error('PDFからのテキスト抽出に失敗しました');
  }
}
