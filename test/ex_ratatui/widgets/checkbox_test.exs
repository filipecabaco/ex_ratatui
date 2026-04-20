defmodule ExRatatui.Widgets.CheckboxTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Checkbox}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Checkbox widget" do
    test "checked checkbox renders symbol and label", %{terminal: terminal} do
      checkbox = %Checkbox{
        label: "Accept terms",
        checked: true,
        checked_style: %Style{fg: :green}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{checkbox, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "[x]"
      assert content =~ "Accept terms"
    end

    test "unchecked checkbox renders symbol and label", %{terminal: terminal} do
      checkbox = %Checkbox{
        label: "Subscribe",
        checked: false
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{checkbox, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "[ ]"
      assert content =~ "Subscribe"
    end

    test "checkbox with custom symbols", %{terminal: terminal} do
      checkbox = %Checkbox{
        label: "Custom",
        checked: true,
        checked_symbol: "✓",
        unchecked_symbol: "✗"
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{checkbox, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "✓"
    end

    test "checkbox with block", %{terminal: terminal} do
      checkbox = %Checkbox{
        label: "Wrapped",
        checked: true,
        block: %Block{title: "Options", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{checkbox, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Options"
      assert content =~ "[x]"
    end
  end
end
