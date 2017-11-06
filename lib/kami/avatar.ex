defmodule Kami.Avatar do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  @versions [:original]

  #def acl(:thumb, _), do: :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  #def transform(:thumb, _) do
  #  {:convert, "-strip -thumbnail 150x150^ -gravity center -extent 150x150 -format png", :png}
  #end

  # Override the persisted filenames:
  #def filename(version, {file, user}) do
  #  "#{user.name}-#{file.file_name}-#{version}"
  #end

  # Override the storage directory:
  def storage_dir(_, {_, scope}) do
    "uploads/user/avatars/#{scope.name}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
