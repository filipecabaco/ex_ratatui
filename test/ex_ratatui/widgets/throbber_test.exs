defmodule ExRatatui.Widgets.ThrobberTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Throbber}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Throbber widget" do
    test "renders throbber with label", %{terminal: terminal} do
      throbber = %Throbber{
        label: "Loading...",
        step: 0,
        throbber_style: %Style{fg: :cyan}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{throbber, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Loading..."
    end

    test "different steps produce different output", %{terminal: terminal} do
      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      # Use non-zero steps to avoid calc_step(0) which picks a random index
      throbber1 = %Throbber{step: 1}
      assert :ok = ExRatatui.draw(terminal, [{throbber1, rect}])
      content1 = ExRatatui.get_buffer_content(terminal)

      throbber3 = %Throbber{step: 3}
      assert :ok = ExRatatui.draw(terminal, [{throbber3, rect}])
      content3 = ExRatatui.get_buffer_content(terminal)

      assert content1 != content3, "Step 1 and step 3 should render different symbols"
    end

    test "throbber with block", %{terminal: terminal} do
      throbber = %Throbber{
        label: "Processing...",
        step: 1,
        block: %Block{title: "Status", borders: [:all], border_type: :rounded}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{throbber, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Status"
    end

    test "throbber with different animation sets", %{terminal: terminal} do
      rect = %Rect{x: 0, y: 0, width: 30, height: 1}

      for set <- [
            :braille,
            :dots,
            :ascii,
            :vertical_block,
            :horizontal_block,
            :arrow,
            :clock,
            :box_drawing,
            :quadrant_block,
            :white_square,
            :white_circle,
            :black_circle
          ] do
        throbber = %Throbber{label: "Test", step: 0, throbber_set: set}
        assert :ok = ExRatatui.draw(terminal, [{throbber, rect}])
      end
    end

    test "throbber struct has correct defaults" do
      throbber = %Throbber{}
      assert throbber.label == ""
      assert throbber.step == 0
      assert throbber.throbber_set == :braille
      assert throbber.style == %Style{}
      assert throbber.throbber_style == %Style{}
      assert throbber.block == nil
    end
  end
end
