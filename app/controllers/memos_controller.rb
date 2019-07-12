class MemosController < ApplicationController
  before_action :set_memo, only: %i[show edit update destroy]
  before_action :search_memos, only: %i[index search search_with_tag]

  # GET /memos
  # GET /memos.json
  def index
  end

  def search
    render partial: 'memos'
  end

  def search_with_tag
    redirect_to memos_search_path(memo_search_form: { keyword: params[:keyword], with_title: false, with_content: false })
  end

  # GET /memos/1
  # GET /memos/1.son
  def show
  end

  # GET /memos/new
  def new
    @memo = Memo.new
  end

  # GET /memos/1/edit
  def edit
  end

  # POST /memos
  # POST /memos.json
  def create
    @memo = Memo.new(memo_params)
    @memo.user_id = @current_user.id
    @memo.tags = new_tags

    respond_to do |format|
      if @memo.save
        format.html { redirect_to @memo, notice: t('.success') }
        format.json { render :show, status: :created, location: @memo }
      else
        handle_errors(model: @memo)
        format.html { render :new }
        format.json { render json: @memo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /memos/1
  # PATCH/PUT /memos/1.json
  def update
    respond_to do |format|
      @memo.tags.replace(new_tags)
      if @memo.update(memo_params)
        format.html { redirect_to @memo, notice: t('.success') }
        format.json { render :show, status: :ok, location: @memo }
      else
        handle_errors(model: @memo)
        format.html { render :edit }
        format.json { render json: @memo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memos/1
  # DELETE /memos/1.json
  def destroy
    @memo.destroy
    respond_to do |format|
      format.html { redirect_to memos_url, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_memo
      @memo = Memo.includes(:tags).find(params[:id])
    end

    def search_memos
      @form = MemoSearchForm.new(memo_search_params)
      @memos = @form.search(@current_user.id)
    end

    def new_tags
      tags_params.map do |param|
        Tag.find_by(param) || Tag.new(param)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def memo_params
      params.require(:memo).permit(:title, :text_content, :draw_content)
    end

    def tags_params
      params[:tags]&.map {|param| param.permit(:name) } || {}
    end

    def memo_search_params
      params[:memo_search_form]&.permit(:keyword, :with_title, :with_content, :with_tag) || {}
    end
end
