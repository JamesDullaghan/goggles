class UploadsController < ApplicationController
  def show
    unless document.present?
      message = "Unable to find the document to upload to the document service"
    end

    unless document.content?
      message = "No OCR'd content for the selected document"
    end

    if document.present?
      document.upload!
      render :index, notice: "Successfully uploaded the document to Open AI"
    else
      flash[:error] = message
      redirect_to documents_path
    end
  end

  private

  def document
    Document.find_by(id: params[:id])
  end
end
