defmodule ExRatatui.Widgets.MarkdownTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Markdown}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Markdown widget" do
    test "renders plain text", %{terminal: terminal} do
      md = %Markdown{content: "Hello world"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Hello world"
    end

    test "renders heading", %{terminal: terminal} do
      md = %Markdown{content: "# Title"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Title"
    end

    test "renders bold text", %{terminal: terminal} do
      md = %Markdown{content: "**bold**"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "bold"
    end

    test "renders inline code", %{terminal: terminal} do
      md = %Markdown{content: "use `code` here"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "code"
    end

    test "renders code block", %{terminal: terminal} do
      md = %Markdown{content: "```\nfn main() {}\n```"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "fn main"
    end

    test "renders bullet list", %{terminal: terminal} do
      md = %Markdown{content: "- item1\n- item2"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "item1"
      assert content =~ "item2"
    end

    test "renders with block", %{terminal: terminal} do
      md = %Markdown{
        content: "Some text",
        block: %Block{title: "Response", borders: [:all], border_type: :rounded}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Response"
    end

    test "renders empty content", %{terminal: terminal} do
      md = %Markdown{content: ""}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw(terminal, [{md, rect}])
    end

    test "markdown struct has correct defaults" do
      md = %Markdown{}
      assert md.content == ""
      assert md.wrap == true
      assert md.scroll == {0, 0}
      assert md.block == nil
      assert md.style == %Style{}
    end
  end
end
