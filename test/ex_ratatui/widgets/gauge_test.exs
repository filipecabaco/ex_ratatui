defmodule ExRatatui.Widgets.GaugeTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Gauge}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Gauge widget" do
    test "basic gauge", %{terminal: terminal} do
      gauge = %Gauge{
        ratio: 0.5,
        gauge_style: %Style{fg: :green}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{gauge, rect}])
    end

    test "gauge with label and block", %{terminal: terminal} do
      gauge = %Gauge{
        ratio: 0.75,
        label: "75%",
        gauge_style: %Style{fg: :blue},
        block: %Block{title: "Progress", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{gauge, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "75%"
      assert content =~ "Progress"
    end

    test "gauge with zero ratio", %{terminal: terminal} do
      gauge = %Gauge{ratio: 0.0}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{gauge, rect}])
    end

    test "gauge with integer ratio coerced to float", %{terminal: terminal} do
      gauge = %Gauge{ratio: 1}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{gauge, rect}])
    end
  end
end
