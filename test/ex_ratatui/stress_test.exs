defmodule ExRatatui.StressTest do
  @moduledoc """
  Stress tests — large scenes, rapid redraws, extreme dimensions.

  Tagged `:slow` so they are excluded from the default `mix test` run.
  Execute explicitly with `mix test --include slow`. These tests assert
  that the pipeline completes without error and produces non-garbage
  output; they deliberately avoid timing assertions (too flaky across
  machines/CI) and instead rely on generous per-test timeouts.
  """

  use ExUnit.Case, async: true

  @moduletag :slow
  @moduletag timeout: 120_000

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.{Block, List, Paragraph, Table}

  describe "large widget trees" do
    test "2000-paragraph tree renders without error" do
      terminal = ExRatatui.init_test_terminal(200, 200)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      widgets =
        for i <- 0..1999 do
          x = rem(i, 40) * 5
          y = div(i, 40)

          {%Paragraph{text: "w#{i}"}, %Rect{x: x, y: y, width: 5, height: 1}}
        end

      assert :ok = ExRatatui.draw(terminal, widgets)

      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "w0"
      assert content =~ "w1999"
    end

    test "list with 10k items renders (clipped to viewport)" do
      terminal = ExRatatui.init_test_terminal(40, 20)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      items = for i <- 0..9999, do: "item-#{i}"
      list = %List{items: items}
      rect = %Rect{x: 0, y: 0, width: 40, height: 20}

      assert :ok = ExRatatui.draw(terminal, [{list, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "item-0"
    end

    test "table with 5k rows renders (clipped to viewport)" do
      terminal = ExRatatui.init_test_terminal(40, 20)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      rows = for i <- 0..4999, do: ["row#{i}", "#{i}"]

      table = %Table{
        rows: rows,
        header: ["name", "n"],
        widths: [{:length, 20}, {:length, 10}]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 20}

      assert :ok = ExRatatui.draw(terminal, [{table, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "row0"
    end

    test "paragraph with 5000-line text renders scrolled" do
      terminal = ExRatatui.init_test_terminal(40, 10)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      text = Enum.map_join(0..4999, "\n", &"line-#{&1}")

      paragraph = %Paragraph{text: text, scroll: {2500, 0}}
      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{paragraph, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "line-2500"
    end
  end

  describe "rapid re-renders" do
    test "1000 draws of a medium scene remain stable" do
      terminal = ExRatatui.init_test_terminal(80, 24)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      for frame <- 1..1000 do
        widgets = [
          {%Block{title: "frame #{frame}", borders: [:all]},
           %Rect{x: 0, y: 0, width: 80, height: 24}},
          {%Paragraph{text: "tick #{frame}"}, %Rect{x: 2, y: 2, width: 30, height: 1}},
          {%List{items: ~w(alpha beta gamma delta)}, %Rect{x: 2, y: 4, width: 30, height: 5}}
        ]

        assert :ok = ExRatatui.draw(terminal, widgets)
      end

      # Final frame content reflects latest draw, not an accumulation.
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "frame 1000"
      assert content =~ "tick 1000"
      refute content =~ "tick 1\n"
    end

    test "500 draws of alternating scenes don't leak state" do
      terminal = ExRatatui.init_test_terminal(40, 10)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      scene_a = [{%Paragraph{text: "AAAA"}, %Rect{x: 0, y: 0, width: 40, height: 10}}]
      scene_b = [{%Paragraph{text: "BBBB"}, %Rect{x: 0, y: 0, width: 40, height: 10}}]

      for i <- 1..500 do
        scene = if rem(i, 2) == 0, do: scene_a, else: scene_b
        assert :ok = ExRatatui.draw(terminal, scene)
      end

      # Last draw was scene_a (500 is even) — no residue of scene_b.
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "AAAA"
      refute content =~ "BBBB"
    end
  end

  describe "extreme terminal dimensions" do
    test "1x1 terminal still renders a single char" do
      terminal = ExRatatui.init_test_terminal(1, 1)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      paragraph = %Paragraph{text: "X"}
      rect = %Rect{x: 0, y: 0, width: 1, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{paragraph, rect}])
      assert ExRatatui.get_buffer_content(terminal) =~ "X"
    end

    test "1-wide, 500-tall terminal renders every row" do
      terminal = ExRatatui.init_test_terminal(1, 500)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      widgets =
        for y <- 0..499 do
          {%Paragraph{text: "x"}, %Rect{x: 0, y: y, width: 1, height: 1}}
        end

      assert :ok = ExRatatui.draw(terminal, widgets)
      content = ExRatatui.get_buffer_content(terminal)
      # Every row has an x — 500 lines total in the buffer.
      assert length(String.split(content, "\n")) == 500
    end

    test "500-wide, 1-tall terminal renders wide paragraph" do
      terminal = ExRatatui.init_test_terminal(500, 1)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      text = String.duplicate("abcdefghij", 50)
      paragraph = %Paragraph{text: text}
      rect = %Rect{x: 0, y: 0, width: 500, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{paragraph, rect}])
      assert ExRatatui.get_buffer_content(terminal) =~ "abcdefghij"
    end

    test "500x500 terminal renders a block covering the whole surface" do
      terminal = ExRatatui.init_test_terminal(500, 500)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      block = %Block{borders: [:all]}
      rect = %Rect{x: 0, y: 0, width: 500, height: 500}

      assert :ok = ExRatatui.draw(terminal, [{block, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "┌"
      assert content =~ "┘"
    end

    test "zero-area rects are a no-op, not a crash" do
      terminal = ExRatatui.init_test_terminal(20, 5)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      widgets = [
        {%Paragraph{text: "visible"}, %Rect{x: 0, y: 0, width: 20, height: 1}},
        {%Paragraph{text: "invisible"}, %Rect{x: 5, y: 2, width: 0, height: 0}},
        {%Paragraph{text: "invisible"}, %Rect{x: 5, y: 3, width: 10, height: 0}},
        {%Paragraph{text: "invisible"}, %Rect{x: 5, y: 4, width: 0, height: 1}}
      ]

      assert :ok = ExRatatui.draw(terminal, widgets)
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "visible"
    end

    test "rect larger than terminal is clipped, not a crash" do
      terminal = ExRatatui.init_test_terminal(20, 5)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      paragraph = %Paragraph{text: "hello"}
      # Rect extends beyond terminal bounds on both axes.
      rect = %Rect{x: 0, y: 0, width: 200, height: 200}

      assert :ok = ExRatatui.draw(terminal, [{paragraph, rect}])
      assert ExRatatui.get_buffer_content(terminal) =~ "hello"
    end
  end

  describe "deeply composed layouts" do
    test "100-way nested horizontal + vertical splits" do
      terminal = ExRatatui.init_test_terminal(200, 100)
      on_exit(fn -> Native.restore_terminal(terminal) end)

      alias ExRatatui.Layout

      rect = %Rect{x: 0, y: 0, width: 200, height: 100}

      # Alternate horizontal/vertical splits, keeping the right/bottom half.
      final =
        Enum.reduce(1..100, rect, fn i, acc ->
          direction = if rem(i, 2) == 0, do: :horizontal, else: :vertical
          [_, keep] = Layout.split(acc, direction, [{:percentage, 50}, {:percentage, 50}])
          keep
        end)

      # After 100 halvings both dimensions collapse — should still be valid.
      assert final.width >= 0
      assert final.height >= 0

      assert :ok =
               ExRatatui.draw(terminal, [
                 {%Paragraph{text: "deep"}, %Rect{x: 0, y: 0, width: 200, height: 1}}
               ])
    end
  end
end
