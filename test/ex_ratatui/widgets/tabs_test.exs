defmodule ExRatatui.Widgets.TabsTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Tabs}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Tabs widget" do
    test "basic tabs with selection", %{terminal: terminal} do
      tabs = %Tabs{
        titles: ["Home", "Settings", "About"],
        selected: 0,
        highlight_style: %Style{fg: :yellow, modifiers: [:bold]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{tabs, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Home"
      assert content =~ "Settings"
      assert content =~ "About"
    end

    test "tabs with custom divider", %{terminal: terminal} do
      tabs = %Tabs{
        titles: ["A", "B", "C"],
        selected: 1,
        divider: " | "
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{tabs, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "|"
    end

    test "tabs with block", %{terminal: terminal} do
      tabs = %Tabs{
        titles: ["Tab 1", "Tab 2"],
        selected: 0,
        block: %Block{title: "Navigation", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{tabs, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Navigation"
      assert content =~ "Tab 1"
    end

    test "tabs with no selection", %{terminal: terminal} do
      tabs = %Tabs{titles: ["X", "Y"]}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{tabs, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "X"
    end
  end
end
