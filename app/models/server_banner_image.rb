# frozen_string_literal: true

class ServerBannerImage < ImageUploadedFileForm
  def copy_errors_to(errors_object, attribute = :banner_image)
    return if valid?

    errors.each do |error|
      errors_object.add(attribute, error.type, **error.options)
    end
  end
end
