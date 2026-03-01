require "test_helper"

class Admin::ServersFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServersFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  def with_stubbed_country_query(data = [["🇺🇸 United States", "US"]])
    fake_instance = Object.new
    fake_instance.define_singleton_method(:call) { data }
    CountrySelectOptionsQuery.stub(:new, ->(**) { fake_instance }) { yield }
  end

  describe "rendering" do
    it "renders status and country selects" do
      with_stubbed_country_query do
        render_inline(described_class.new(form: build_form))
      end

      assert_selector("select[name='status']")
      assert_selector("select[name='country_code']")
      assert_selector("select[name='status'][aria-label='Status']")
    end

    it "shows clear button when filters are active" do
      with_stubbed_country_query([]) do
        render_inline(described_class.new(
          form: build_form,
          selected_value_status: "verified"
        ))
      end

      assert_selector("a.btn", text: "Clear")
    end

    it "includes hidden fields for q, sort, sort_dir when present in request" do
      req = build_request(url: "http://uppertown.test/admin/servers?q=my+search&sort=name&sort_dir=asc")
      with_stubbed_country_query([]) do
        render_inline(described_class.new(
          form: build_form,
          request: req
        ))
      end

      assert_selector("input[type='hidden'][name='q']", visible: :all)
      input = page.find("input[name='q']", visible: :all)
      assert_equal("my search", input.value)
    end
  end

  describe "#has_active_filters?" do
    it "returns true when status is present" do
      component = described_class.new(form: build_form, selected_value_status: "verified")

      assert(component.has_active_filters?)
    end

    it "returns true when country_code is present" do
      component = described_class.new(form: build_form, selected_value_country_code: "US")

      assert(component.has_active_filters?)
    end

    it "returns false when no filters are set" do
      component = described_class.new(form: build_form)

      assert_not(component.has_active_filters?)
    end
  end
end
