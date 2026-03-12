defmodule OxideTest do
  use ExUnit.Case, async: true

  describe "extract/2" do
    test "extracts candidates from HTML" do
      candidates = Oxide.extract(~s(class="flex bg-red-500 hover:text-white"), "html")
      values = Enum.map(candidates, & &1.value)
      assert "flex" in values
      assert "bg-red-500" in values
      assert "hover:text-white" in values
    end

    test "extracts from HEEx templates" do
      candidates = Oxide.extract(~s(<div class="mt-4 p-2">hello</div>), "heex")
      values = Enum.map(candidates, & &1.value)
      assert "mt-4" in values
      assert "p-2" in values
    end

    test "extracts from Elixir source" do
      code = ~s(~H\"""<div class="flex items-center">hi</div>\""")
      candidates = Oxide.extract(code, "ex")
      values = Enum.map(candidates, & &1.value)
      assert "flex" in values
      assert "items-center" in values
    end

    test "extracts from Vue templates" do
      candidates = Oxide.extract(~s(<div class="grid grid-cols-3 gap-4">), "vue")
      values = Enum.map(candidates, & &1.value)
      assert "grid" in values
      assert "grid-cols-3" in values
      assert "gap-4" in values
    end

    test "returns positions" do
      candidates = Oxide.extract(~s(class="flex"), "html")
      assert Enum.any?(candidates, &(&1.position > 0))
    end

    test "returns empty list for empty input" do
      assert Oxide.extract("", "html") == []
    end
  end

  describe "new/1 + scan/1" do
    @fixture_dir Path.expand("fixtures/scan_test", __DIR__)

    setup do
      File.mkdir_p!(@fixture_dir)

      File.write!(Path.join(@fixture_dir, "page.html"), """
      <div class="flex items-center justify-between">
        <span class="text-lg font-bold">Title</span>
        <button class="px-4 py-2 bg-blue-500 rounded">Click</button>
      </div>
      """)

      File.write!(Path.join(@fixture_dir, "app.ex"), """
      defmodule App do
        def render(assigns) do
          ~H\"\"\"
          <div class="mt-8 space-y-4">
            <p class="text-gray-600">Hello</p>
          </div>
          \"\"\"
        end
      end
      """)

      on_exit(fn -> File.rm_rf!(@fixture_dir) end)
      :ok
    end

    test "scans directory for candidates" do
      scanner = Oxide.new(sources: [%{base: @fixture_dir, pattern: "**/*"}])
      candidates = Oxide.scan(scanner)

      assert "flex" in candidates
      assert "items-center" in candidates
      assert "bg-blue-500" in candidates
      assert "mt-8" in candidates
      assert "text-gray-600" in candidates
    end

    test "returns files discovered" do
      scanner = Oxide.new(sources: [%{base: @fixture_dir, pattern: "**/*"}])
      _candidates = Oxide.scan(scanner)
      files = Oxide.files(scanner)

      assert Enum.any?(files, &String.ends_with?(&1, "page.html"))
      assert Enum.any?(files, &String.ends_with?(&1, "app.ex"))
    end

    test "incremental scan returns only new candidates" do
      scanner = Oxide.new(sources: [%{base: @fixture_dir, pattern: "**/*"}])
      _initial = Oxide.scan(scanner)

      new =
        Oxide.scan_files(scanner, [
          %{content: ~s(class="flex hidden sm:block"), extension: "html"}
        ])

      assert "hidden" in new
      assert "sm:block" in new
      refute "flex" in new
    end
  end
end
