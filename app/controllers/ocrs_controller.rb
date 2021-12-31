class OcrsController < ApplicationController
  def show
    document = Document.find_by(id: params[:id])
    document.ocr!

    redirect_to document_path(id: document.id)
  end
end
