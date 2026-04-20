defmodule ExRatatui.Widgets.ChartTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Chart}
  alias ExRatatui.Widgets.Chart.{Axis, Dataset}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Chart widget" do
    defp simple_chart(opts \\ []) do
      datasets =
        Keyword.get(opts, :datasets, [
          %Dataset{name: "cpu", data: [{0.0, 1.0}, {5.0, 5.0}, {10.0, 9.0}]}
        ])

      %Chart{
        datasets: datasets,
        x_axis: %Axis{bounds: {0.0, 10.0}},
        y_axis: %Axis{bounds: {0.0, 10.0}},
        legend_position: Keyword.get(opts, :legend_position, :top_right),
        hidden_legend_constraints: Keyword.get(opts, :hidden_legend_constraints),
        block: Keyword.get(opts, :block)
      }
    end

    test "renders a line chart with legend", %{terminal: terminal} do
      chart = simple_chart()
      rect = %Rect{x: 0, y: 0, width: 50, height: 12}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "cpu"
    end

    test "renders a scatter chart", %{terminal: terminal} do
      chart =
        simple_chart(
          datasets: [
            %Dataset{
              name: "pts",
              data: [{1.0, 2.0}, {4.0, 5.0}, {7.0, 8.0}],
              graph_type: :scatter,
              marker: :dot
            }
          ]
        )

      rect = %Rect{x: 0, y: 0, width: 50, height: 12}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
    end

    test "renders a bar graph_type chart", %{terminal: terminal} do
      chart =
        simple_chart(
          datasets: [
            %Dataset{name: "freq", data: [{0.0, 3.0}, {1.0, 5.0}], graph_type: :bar}
          ]
        )

      rect = %Rect{x: 0, y: 0, width: 50, height: 12}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
    end

    test "renders multiple datasets with shared axes", %{terminal: terminal} do
      chart =
        simple_chart(
          datasets: [
            %Dataset{name: "cpu", data: [{0.0, 1.0}, {10.0, 9.0}]},
            %Dataset{
              name: "mem",
              data: [{0.0, 8.0}, {10.0, 5.0}],
              style: %Style{fg: :magenta}
            }
          ]
        )

      rect = %Rect{x: 0, y: 0, width: 60, height: 14}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "cpu"
      assert content =~ "mem"
    end

    test "legend_position: nil hides the legend", %{terminal: terminal} do
      chart =
        simple_chart(
          datasets: [%Dataset{name: "secret", data: [{0.0, 1.0}, {10.0, 9.0}]}],
          legend_position: nil
        )

      rect = %Rect{x: 0, y: 0, width: 50, height: 12}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "secret"
    end

    test "hidden_legend_constraints suppresses legend in tight area", %{terminal: terminal} do
      chart =
        simple_chart(
          datasets: [%Dataset{name: "tight", data: [{0.0, 1.0}, {10.0, 9.0}]}],
          hidden_legend_constraints: {{:length, 3}, {:length, 1}}
        )

      rect = %Rect{x: 0, y: 0, width: 20, height: 6}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "tight"
    end

    test "renders axis title and labels", %{terminal: terminal} do
      chart = %Chart{
        datasets: [%Dataset{name: "a", data: [{0.0, 1.0}, {10.0, 9.0}]}],
        x_axis: %Axis{title: "X-Axis", bounds: {0.0, 10.0}, labels: ["0", "5", "10"]},
        y_axis: %Axis{bounds: {0.0, 10.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 50, height: 12}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "X-Axis"
    end

    test "renders with block title", %{terminal: terminal} do
      chart =
        simple_chart(block: %Block{title: "Trend", borders: [:all]})

      rect = %Rect{x: 0, y: 0, width: 50, height: 12}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Trend"
    end

    test "empty datasets render without crash", %{terminal: terminal} do
      chart = simple_chart(datasets: [])
      rect = %Rect{x: 0, y: 0, width: 30, height: 8}
      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
    end

    test "accepts every legend position", %{terminal: terminal} do
      rect = %Rect{x: 0, y: 0, width: 50, height: 12}

      for position <- [
            :top,
            :top_left,
            :top_right,
            :bottom,
            :bottom_left,
            :bottom_right,
            :left,
            :right
          ] do
        chart = simple_chart(legend_position: position)
        assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      end
    end

    test "chart struct has correct defaults" do
      chart = %Chart{}
      assert chart.datasets == []
      assert chart.x_axis == nil
      assert chart.y_axis == nil
      assert chart.legend_position == :top_right
      assert chart.hidden_legend_constraints == nil
      assert chart.block == nil
    end

    test "dataset struct has correct defaults" do
      dataset = %Dataset{}
      assert dataset.name == nil
      assert dataset.data == []
      assert dataset.marker == :braille
      assert dataset.graph_type == :line
      assert dataset.style == %Style{}
    end

    test "axis struct has correct defaults" do
      axis = %Axis{}
      assert axis.title == nil
      assert axis.bounds == nil
      assert axis.labels == []
      assert axis.style == %Style{}
      assert axis.labels_alignment == :left
    end

    test "rejects missing x_axis" do
      chart = %Chart{x_axis: nil, y_axis: %Axis{bounds: {0.0, 1.0}}}
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/x_axis is required/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects missing y_axis" do
      chart = %Chart{x_axis: %Axis{bounds: {0.0, 1.0}}, y_axis: nil}
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/y_axis is required/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-list datasets" do
      chart = %Chart{
        datasets: "not a list",
        x_axis: %Axis{bounds: {0.0, 1.0}},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/list of %ExRatatui.Widgets.Chart.Dataset\{\}/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-Dataset entries in datasets" do
      chart = %Chart{
        datasets: [{:not, :a, :dataset}],
        x_axis: %Axis{bounds: {0.0, 1.0}},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/entries to be %ExRatatui.Widgets.Chart.Dataset\{\}/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-list dataset data" do
      chart = simple_chart(datasets: [%Dataset{name: "x", data: "nope"}])
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/list of \{x, y\} numeric tuples/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-tuple data points" do
      chart = simple_chart(datasets: [%Dataset{name: "x", data: [[1.0, 2.0]]}])
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/\{number, number\} tuples/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects unknown marker" do
      chart = simple_chart(datasets: [%Dataset{data: [{0.0, 1.0}], marker: :pixel}])
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/marker expected one of/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects unknown graph_type" do
      chart = simple_chart(datasets: [%Dataset{data: [{0.0, 1.0}], graph_type: :pie}])
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/graph_type expected one of/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-string dataset name" do
      chart = simple_chart(datasets: [%Dataset{name: 123, data: [{0.0, 1.0}]}])
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/name expected a string or nil/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects unknown legend_position" do
      chart = simple_chart(legend_position: :middle)
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/legend_position expected/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects malformed hidden_legend_constraints" do
      chart = simple_chart(hidden_legend_constraints: {:not_a_pair})
      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/hidden_legend_constraints expected/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-Axis x_axis" do
      chart = %Chart{
        datasets: [],
        x_axis: %{bounds: {0.0, 1.0}},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/expected %ExRatatui.Widgets.Chart.Axis\{\}/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects bad axis bounds" do
      chart = %Chart{
        datasets: [],
        x_axis: %Axis{bounds: {:a, :b}},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/bounds expected \{min, max\}/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects unknown labels_alignment" do
      chart = %Chart{
        datasets: [],
        x_axis: %Axis{bounds: {0.0, 1.0}, labels_alignment: :justify},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/labels_alignment expected one of/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end

    test "rejects non-list axis labels" do
      chart = %Chart{
        datasets: [],
        x_axis: %Axis{bounds: {0.0, 1.0}, labels: "nope"},
        y_axis: %Axis{bounds: {0.0, 1.0}}
      }

      rect = %Rect{x: 0, y: 0, width: 10, height: 4}

      assert_raise ArgumentError, ~r/labels expected a list/, fn ->
        ExRatatui.Bridge.encode_commands!([{chart, rect}])
      end
    end
  end
end
