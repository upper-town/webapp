require "test_helper"

class Admin::TableComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::TableComponent }

  describe "rendering" do
    it "renders empty message when collection is empty" do
      render_inline(described_class.new(
                      collection: [],
                      columns: [["Name", :name]],
                      empty_message: "No results"
                    ))

      assert_selector(".card-body", text: "No results")
      assert_no_selector("table")
    end

    it "renders custom empty message" do
      render_inline(described_class.new(
                      collection: [],
                      columns: [],
                      empty_message: "No games found"
                    ))

      assert_selector(".card-body", text: "No games found")
    end

    it "renders table with string column values" do
      user = create_user
      columns = [["Email", user.email]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("table.admin-table")
      assert_selector("th", text: "Email")
      assert_selector("td", text: user.email)
    end

    it "renders table with symbol column (calls method on item)" do
      user = create_user
      columns = [["Email", :email]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("td", text: user.email)
    end

    it "renders table with proc column" do
      user = create_user
      columns = [["Email", ->(u) { u.email.upcase }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("td", text: user.email.upcase)
    end

    it "renders copy button when column has copyable option" do
      user = create_user
      columns = [["Email", :email, { copyable: true }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("[data-controller='copy-to-clipboard']")
      assert_selector("button[data-copy-btn]")
      assert_selector("[data-copy-to-clipboard-value='#{user.email}']")
    end

    it "renders copy button with copyable as symbol" do
      user = create_user
      columns = [["Email", :email, { copyable: :email }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("[data-copy-to-clipboard-value='#{user.email}']")
    end

    it "renders copy button with copyable as proc" do
      user = create_user
      columns = [["Email", :email, { copyable: ->(u) { "copy-#{u.email}" } }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("[data-copy-to-clipboard-value='copy-#{user.email}']")
    end

    it "renders cell without copy when copyable value is blank" do
      user = create_user
      columns = [["Locked", :locked_at, { copyable: true }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_no_selector("button[data-copy-btn]")
      assert_selector("td") # Cell still renders
    end

    it "renders multiple columns" do
      user = create_user
      columns = [
        ["Email", :email],
        ["ID", :id]
      ]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("th", text: "Email")
      assert_selector("th", text: "ID")
      assert_selector("td", text: user.email)
      assert_selector("td", text: user.id.to_s)
    end

    it "renders multiple rows" do
      users = [create_user, create_user]
      columns = [["Email", :email]]
      render_inline(described_class.new(collection: users, columns:))

      assert_selector("tbody tr", count: 2)
      assert_text(users[0].email)
      assert_text(users[1].email)
    end

    it "applies column alignment when align option is set" do
      user = create_user
      columns = [
        ["Email", :email],
        ["ID", :id, { align: :end }],
        ["Status", :email_confirmed_at, { align: :center }]
      ]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("th.text-end", text: "ID")
      assert_selector("th.text-center", text: "Status")
      assert_selector("td.text-end", text: user.id.to_s)
      assert_selector("td.text-center")
    end

    it "renders sortable column as link when sort_url_builder provided" do
      user = create_user
      sort_url_builder = ->(key, dir) { "/admin?sort=#{key}&sort_dir=#{dir}" }
      columns = [["Email", :email, { sortable: "email" }]]
      render_inline(described_class.new(
        collection: [user],
        columns:,
        sort_url_builder:
      ))

      assert_selector("th a.admin-table-sort-link[href='/admin?sort=email&sort_dir=asc']", text: "Email")
    end

    it "renders non-sortable column as plain text" do
      user = create_user
      sort_url_builder = ->(key, dir) { "/admin?sort=#{key}&sort_dir=#{dir}" }
      columns = [
        ["Email", :email, { sortable: "email" }],
        ["ID", :id]
      ]
      render_inline(described_class.new(
        collection: [user],
        columns:,
        sort_url_builder:
      ))

      assert_selector("th a.admin-table-sort-link", count: 1)
      assert_selector("th", text: "ID")
      assert_no_selector("th a", text: "ID")
    end

    it "renders no sort links when sort_url_builder is nil" do
      user = create_user
      columns = [["Email", :email, { sortable: "email" }]]
      render_inline(described_class.new(collection: [user], columns:))

      assert_selector("th", text: "Email")
      assert_no_selector("th a.admin-table-sort-link")
    end
  end

  describe "#empty?" do
    it "returns true when collection is empty" do
      component = described_class.new(collection: [], columns: [])

      assert_empty(component)
    end

    it "returns false when collection has items" do
      component = described_class.new(collection: [create_user], columns: [])

      assert_not(component.empty?)
    end
  end

  describe "#column_name" do
    it "returns first element of column" do
      component = described_class.new(collection: [], columns: [])

      assert_equal("Name", component.column_name(["Name", :name]))
    end
  end

  describe "#column_value" do
    it "returns second element of column" do
      component = described_class.new(collection: [], columns: [])

      assert_equal(:email, component.column_value(["Email", :email]))
    end
  end

  describe "#column_opts" do
    it "returns third element when column has 3+ elements" do
      component = described_class.new(collection: [], columns: [])
      opts = { copyable: true }

      assert_equal(opts, component.column_opts(["Email", :email, opts]))
    end

    it "returns nil when column has fewer than 3 elements" do
      component = described_class.new(collection: [], columns: [])

      assert_nil(component.column_opts(["Email", :email]))
    end
  end

  describe "#show_copy?" do
    it "returns true when column opts have copyable key" do
      component = described_class.new(collection: [], columns: [])

      assert(component.show_copy?(["Email", :email, { copyable: true }]))
    end

    it "returns false when column opts lack copyable" do
      component = described_class.new(collection: [], columns: [])

      assert_not(component.show_copy?(["Email", :email]))
      assert_not(component.show_copy?(["Email", :email, { align_top: true }]))
    end
  end

  describe "#cell_value" do
    it "returns string for string column" do
      user = create_user
      component = described_class.new(collection: [], columns: [])

      assert_equal("static", component.cell_value(user, "static"))
    end

    it "returns item attribute for symbol column" do
      user = create_user
      component = described_class.new(collection: [], columns: [])

      assert_equal(user.email, component.cell_value(user, :email))
    end

    it "returns nil for blank attribute" do
      user = create_user
      component = described_class.new(collection: [], columns: [])

      assert_nil(component.cell_value(user, :locked_at))
    end

    it "calls proc for proc column" do
      user = create_user
      component = described_class.new(collection: [], columns: [])

      assert_equal("PROC", component.cell_value(user, ->(_) { "PROC" }))
    end
  end
end
