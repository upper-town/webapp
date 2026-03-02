class ApplicationComponent < ViewComponent::Base
  def normalize_ids(ids)
    Array(ids).map(&:to_s).compact_blank
  end

  def normalize_param_name(name)
    name.to_s.delete_suffix("[]")
  end
end
