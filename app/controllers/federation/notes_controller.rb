module Federation
  class NotesController < FederationApplicationController
    before_action :set_note, only: [:show]

    def show; end

    private

    def set_note
      @note = Note.find_by!(actor_id: params[:actor_id], id: params[:id])
      authorize @note
    end
  end
end

