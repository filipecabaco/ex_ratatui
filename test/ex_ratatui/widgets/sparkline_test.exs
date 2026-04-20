defmodule ExRatatui.Widgets.SparklineTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Sparkline}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Sparkline widget" do
    test "basic left-to-right data renders", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [0, 1, 3, 5, 8, 3, 1],
        style: %Style{fg: :cyan}
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
    end

    test "right-to-left direction renders", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [1, 2, 8],
        direction: :right_to_left,
        max: 8
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
    end

    test "auto-scales when max is nil", %{terminal: terminal} do
      sparkline = %Sparkline{data: [5, 10, 15]}
      rect = %Rect{x: 0, y: 0, width: 10, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
    end

    test "absent value renders with custom symbol", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [1, nil, 5],
        max: 5,
        absent_value_symbol: "?",
        absent_value_style: %Style{fg: :red}
      }

      rect = %Rect{x: 0, y: 0, width: 6, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "?"
    end

    test "three_levels bar_set preset renders", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [0, 4, 8],
        max: 8,
        bar_set: :three_levels
      }

      rect = %Rect{x: 0, y: 0, width: 6, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
    end

    test "custom bar_set list renders", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [0, 2, 5, 8],
        max: 8,
        bar_set: [".", "o", "O"]
      }

      rect = %Rect{x: 0, y: 0, width: 8, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "O"
    end

    test "with block title renders", %{terminal: terminal} do
      sparkline = %Sparkline{
        data: [1, 2, 3, 4],
        block: %Block{title: " CPU ", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "CPU"
    end

    test "empty data list renders", %{terminal: terminal} do
      sparkline = %Sparkline{data: []}
      rect = %Rect{x: 0, y: 0, width: 10, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{sparkline, rect}])
    end
  end
end
