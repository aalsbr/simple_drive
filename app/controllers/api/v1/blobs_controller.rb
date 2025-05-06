module Api
  module V1
    class BlobsController < ApplicationController
      # Authentication is handled by ApplicationController

      # GET /api/v1/blobs/:id
      def show
        response = blob_service.find(params[:id])
        
        if response.successful?
          # Return only the specific fields requested
          render json: { id: response.data[:id], data: response.data[:data], size: response.data[:size], created_at: response.data[:created_at] }, status: response.status
        else
          render json: response.to_hash, status: response.status
        end
      end

      # POST /api/v1/blobs
      def create
        # Validate parameters
        unless params[:blob_id].present? && params[:data].present?
          render json: {
            success: false,
            message: I18n.t('blobs.errors.missing_parameters'),
            details: I18n.t('blobs.errors.missing_parameters_details')
          }, status: :unprocessable_entity
          return
        end

        # Delegate to service layer
        response = blob_service.create(params[:blob_id], params[:data])
        render json: response.to_hash, status: response.status
      end

      private

      def blob_service
        @blob_service ||= BlobService.new
      end

      # Authentication is now handled by ApplicationController with JWT tokens
    end
  end
end
