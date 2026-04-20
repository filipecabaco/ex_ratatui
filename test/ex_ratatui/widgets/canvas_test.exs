defmodule ExRatatui.Widgets.CanvasTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.{Block, Canvas}
  alias ExRatatui.Widgets.Canvas.{Circle, Line, Points, Rectangle}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Canvas widget" do
    test "renders a line", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [%Line{x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0, color: :red}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders a rectangle", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [%Rectangle{x: 1.0, y: 1.0, width: 5.0, height: 3.0, color: :green}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders a circle", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [%Circle{x: 5.0, y: 5.0, radius: 3.0, color: :yellow}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders points", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [%Points{coords: [{1.0, 1.0}, {2.0, 3.0}], color: :magenta}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders with dot marker", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        marker: :dot,
        shapes: [%Points{coords: [{5.0, 5.0}], color: :white}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders with background color", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        background_color: :blue,
        shapes: []
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "renders multiple shapes stacked", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [
          %Line{x1: 0.0, y1: 0.0, x2: 10.0, y2: 0.0, color: :red},
          %Circle{x: 5.0, y: 5.0, radius: 2.0, color: :blue}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "empty shapes list renders", %{terminal: terminal} do
      canvas = %Canvas{x_bounds: {0.0, 10.0}, y_bounds: {0.0, 10.0}, shapes: []}
      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end

    test "canvas with block title renders", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0.0, 10.0},
        y_bounds: {0.0, 10.0},
        shapes: [%Points{coords: [{5.0, 5.0}], color: :white}],
        block: %Block{title: " Plot ", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
      assert ExRatatui.get_buffer_content(terminal) =~ "Plot"
    end

    test "integer coordinates are coerced to floats", %{terminal: terminal} do
      canvas = %Canvas{
        x_bounds: {0, 10},
        y_bounds: {0, 10},
        shapes: [%Line{x1: 0, y1: 0, x2: 10, y2: 10, color: :cyan}]
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{canvas, rect}])
    end
  end
end
