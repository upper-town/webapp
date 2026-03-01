require "test_helper"

class Admin::SimpleFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::SimpleFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  def build_request_with_params(url_with_query)
    build_request(url: url_with_query)
  end

  describe "rendering" do
    it "renders content block" do
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: false,
        params_to_remove: []
      )) do
        "Filter fields"
      end

      assert_text("Filter fields")
    end

    it "renders hidden fields from request query via RequestHelper" do
      req = build_request_with_params("http://uppertown.test/admin/servers?q=search&sort=name")
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: false,
        params_to_remove: [],
        request: req
      )) do
        "Fields"
      end

      assert_selector("input[type='hidden'][name='q'][value='search']", visible: :all)
      assert_selector("input[type='hidden'][name='sort'][value='name']", visible: :all)
    end

    it "excludes params in params_to_remove from hidden fields" do
      req = build_request_with_params("http://uppertown.test/admin/servers?q=foo&status=verified&country_code=US")
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: false,
        params_to_remove: %w[status country_code],
        request: req
      )) do
        "Fields"
      end

      assert_selector("input[type='hidden'][name='q'][value='foo']", visible: :all)
      assert_no_selector("input[type='hidden'][name='status']", visible: :all)
      assert_no_selector("input[type='hidden'][name='country_code']", visible: :all)
    end

    it "preserves array params and excludes game_ids[] when in params_to_remove" do
      req = build_request_with_params("http://uppertown.test/admin/servers?q=bar&game_ids[]=1&game_ids[]=2&sort=name")
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: false,
        params_to_remove: %w[game_ids[]],
        request: req
      )) do
        "Fields"
      end

      assert_selector("input[type='hidden'][name='q'][value='bar']", visible: :all)
      assert_selector("input[type='hidden'][name='sort'][value='name']", visible: :all)
      assert_no_selector("input[type='hidden'][name='game_ids[]']", visible: :all)
    end

    it "renders clear button when has_active_filters is true" do
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: true,
        params_to_remove: []
      )) do
        "Fields"
      end

      assert_selector("a.btn", text: I18n.t("admin.shared.clear_search"))
    end

    it "does not render clear button when has_active_filters is false" do
      render_inline(described_class.new(
        form: build_form,
        has_active_filters: false,
        params_to_remove: []
      )) do
        "Fields"
      end

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end

    it "has d-flex layout classes" do
      render_inline(described_class.new(
        form: build_form,
        params_to_remove: []
      )) do
        "Fields"
      end

      assert_selector("div.d-flex.align-items-center.gap-2.flex-wrap")
    end
  end

  describe "attr_readers" do
    it "exposes form, clear_url, has_active_filters, params_to_remove" do
      form = build_form
      req = build_request_with_params("http://uppertown.test/admin/servers?x=1")
      component = described_class.new(
        form: form,
        has_active_filters: true,
        params_to_remove: %w[status],
        request: req
      )
      render_inline(component) { "Fields" }

      assert_equal(form, component.form)
      assert_includes(component.clear_url, "x=1")
      assert_not_includes(component.clear_url, "status")
      assert(component.has_active_filters)
      assert_equal(%w[status], component.params_to_remove)
    end
  end
end
