# Building UIs

This guide covers the building blocks for constructing screens in `render/2`: widgets, layout, styles, and events. Everything here works identically in both the [Callback Runtime](callback_runtime.md) and [Reducer Runtime](reducer_runtime.md).

## Layout

`render/2` returns a list of `{widget, rect}` tuples. Each `%ExRatatui.Layout.Rect{}` defines a rectangular area on the screen. Use `ExRatatui.Layout.split/3` to divide areas into sub-regions using constraints:

```elixir
alias ExRatatui.Layout
alias ExRatatui.Layout.Rect

area = %Rect{x: 0, y: 0, width: 80, height: 24}

# Three-row layout: header, body, footer
[header, body, footer] = Layout.split(area, :vertical, [
  {:length, 3},
  {:min, 0},
  {:length, 1}
])

# Split body into sidebar + main
[sidebar, main] = Layout.split(body, :horizontal, [
  {:percentage, 30},
  {:percentage, 70}
])
```

### Constraint Types

| Constraint | Description |
|------------|-------------|
| `{:percentage, n}` | Percentage of the available space (0–100) |
| `{:length, n}` | Exact number of rows or columns |
| `{:min, n}` | At least `n` rows/columns, expands to fill remaining space |
| `{:max, n}` | At most `n` rows/columns |
| `{:ratio, num, den}` | Fraction of available space (e.g., `{:ratio, 1, 3}` for one-third) |

## Styles

Styles control foreground color, background color, and text modifiers:

```elixir
alias ExRatatui.Style

# Named colors
%Style{fg: :green, bg: :black}

# RGB
%Style{fg: {:rgb, 255, 100, 0}}

# 256-color indexed
%Style{fg: {:indexed, 42}}

# Modifiers
%Style{modifiers: [:bold, :dim, :italic, :underlined, :crossed_out, :reversed]}
```

Named colors: `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:gray`, `:dark_gray`, `:light_red`, `:light_green`, `:light_yellow`, `:light_blue`, `:light_magenta`, `:light_cyan`, `:white`, `:reset`.

Styles can be applied to most widgets via the `:style` field, and many widgets accept additional style fields for specific parts (e.g., `highlight_style`, `border_style`).

## Events

Terminal events are polled automatically by the runtime. In the [Callback Runtime](callback_runtime.md), they arrive in `handle_event/2`. In the [Reducer Runtime](reducer_runtime.md), they arrive as `{:event, event}` in `update/2`.

### Key Events

```elixir
%ExRatatui.Event.Key{
  code: "q",          # key name: "a"-"z", "up", "down", "enter", "esc", "tab", etc.
  kind: "press",      # "press", "release", or "repeat"
  modifiers: []       # list of "ctrl", "alt", "shift", "super", "hyper", "meta"
}
```

### Mouse Events

```elixir
%ExRatatui.Event.Mouse{
  kind: "down",       # "down", "up", "drag", "moved", "scroll_down", "scroll_up"
  column: 10,
  row: 5,
  modifiers: []
}
```

### Resize Events

```elixir
%ExRatatui.Event.Resize{
  width: 120,
  height: 40
}
```

The runtime automatically re-renders on resize — you don't need to handle resize events unless your app needs to react to size changes in its state.

## Widgets

### Paragraph

Text display with alignment, wrapping, and scrolling.

```elixir
%Paragraph{
  text: "Hello, world!\nSecond line.",
  style: %Style{fg: :cyan, modifiers: [:bold]},
  alignment: :center,
  wrap: true
}
```

### Block

Container with borders and title. Can wrap any other widget via the `:block` field.

```elixir
%Block{
  title: "My Panel",
  borders: [:all],
  border_type: :rounded,
  border_style: %Style{fg: :blue}
}

# Compose with other widgets:
%Paragraph{
  text: "Inside a box",
  block: %Block{title: "Title", borders: [:all]}
}
```

Border types: `:plain`, `:rounded`, `:double`, `:thick`.

### List

Selectable list with highlight support.

```elixir
%List{
  items: ["Elixir", "Rust", "Haskell"],
  highlight_style: %Style{fg: :yellow, modifiers: [:bold]},
  highlight_symbol: " > ",
  selected: 0,
  block: %Block{title: " Languages ", borders: [:all]}
}
```

### Table

Table with headers, rows, and column width constraints.

```elixir
%Table{
  rows: [["Alice", "30"], ["Bob", "25"]],
  header: ["Name", "Age"],
  widths: [{:length, 15}, {:length, 10}],
  highlight_style: %Style{fg: :yellow},
  selected: 0
}
```

### Gauge

Progress bar.

```elixir
%Gauge{
  ratio: 0.75,
  label: "75%",
  gauge_style: %Style{fg: :green}
}
```

### LineGauge

Thin single-line progress bar with separate filled/unfilled styles.

```elixir
%LineGauge{
  ratio: 0.6,
  label: "60%",
  filled_style: %Style{fg: :green},
  unfilled_style: %Style{fg: :dark_gray}
}
```

### Tabs

Tab bar for switching between views.

```elixir
%Tabs{
  titles: ["Home", "Settings", "Help"],
  selected: 0,
  highlight_style: %Style{fg: :cyan, modifiers: [:bold]},
  divider: " | ",
  block: %Block{borders: [:all]}
}
```

### Scrollbar

Scroll position indicator for long content. Supports vertical and horizontal orientations.

```elixir
%Scrollbar{
  content_length: 100,
  position: 25,
  viewport_content_length: 10,
  orientation: :vertical_right,
  thumb_style: %Style{fg: :cyan}
}
```

Orientations: `:vertical_right`, `:vertical_left`, `:horizontal_bottom`, `:horizontal_top`.

### Checkbox

Boolean toggle with customizable symbols.

```elixir
%Checkbox{
  label: "Enable notifications",
  checked: true,
  checked_style: %Style{fg: :green},
  checked_symbol: "✓",
  unchecked_symbol: "✗"
}
```

### TextInput

Single-line text input with cursor navigation and viewport scrolling. This is a **stateful** widget — its state lives in Rust via ResourceArc.

```elixir
# Create state (once, e.g. in mount/1 or init/1)
state = ExRatatui.text_input_new()

# Forward key events
ExRatatui.text_input_handle_key(state, "h")
ExRatatui.text_input_handle_key(state, "i")

# Read/set value
ExRatatui.text_input_get_value(state)  #=> "hi"
ExRatatui.text_input_set_value(state, "hello")

# Render
%TextInput{
  state: state,
  style: %Style{fg: :white},
  cursor_style: %Style{fg: :black, bg: :white},
  placeholder: "Type here...",
  placeholder_style: %Style{fg: :dark_gray},
  block: %Block{title: "Search", borders: [:all], border_type: :rounded}
}
```

### Clear

Resets all cells in its area to empty (space) characters. Useful for rendering overlays on top of existing content.

```elixir
%Clear{}
```

### Markdown

Renders markdown with syntax-highlighted code blocks. Powered by `tui-markdown` (pulldown-cmark + syntect). Supports headings, bold, italic, inline code, fenced code blocks, bullet lists, links, and horizontal rules.

```elixir
%Markdown{
  content: "# Hello\n\nSome **bold** text and `inline code`.\n\n```elixir\nIO.puts(\"hi\")\n```",
  wrap: true,
  block: %Block{title: "Response", borders: [:all]}
}
```

### Textarea

Multiline text editor with undo/redo, cursor movement, and Emacs-style shortcuts. This is a **stateful** widget — state lives in Rust via ResourceArc.

```elixir
# Create state (once, e.g. in mount/1 or init/1)
state = ExRatatui.textarea_new()

# Forward key events (with modifier support)
ExRatatui.textarea_handle_key(state, "h", [])
ExRatatui.textarea_handle_key(state, "enter", [])
ExRatatui.textarea_handle_key(state, "w", ["ctrl"])  # delete word backward

# Read value
ExRatatui.textarea_get_value(state)  #=> "h\n"

# Render
%Textarea{
  state: state,
  placeholder: "Type your message...",
  placeholder_style: %Style{fg: :dark_gray},
  block: %Block{title: "Message", borders: [:all], border_type: :rounded}
}
```

### Throbber

Loading spinner that animates through symbol sets. The caller controls animation by incrementing `:step` on each tick.

```elixir
%Throbber{
  label: "Loading...",
  step: state.tick,
  throbber_set: :braille,
  throbber_style: %Style{fg: :cyan},
  block: %Block{title: "Status", borders: [:all]}
}
```

Available sets: `:braille`, `:dots`, `:ascii`, `:vertical_block`, `:horizontal_block`, `:arrow`, `:clock`, `:box_drawing`, `:quadrant_block`, `:white_square`, `:white_circle`, `:black_circle`.

### Popup

Centered modal overlay. Renders any widget centered over the parent area, clearing the background underneath. Useful for dialogs, confirmations, and command palettes.

```elixir
%Popup{
  content: %Paragraph{text: "Are you sure?"},
  block: %Block{title: "Confirm", borders: [:all], border_type: :rounded},
  percent_width: 50,
  percent_height: 30
}
```

### WidgetList

Vertical list of heterogeneous widgets with optional selection and scrolling. Each item is a `{widget, height}` tuple. Ideal for chat message histories where items have different heights.

`scroll_offset` is a row offset from the top of the content, not an item index. To scroll to a specific item, sum the heights of all preceding items. Items partially above the viewport are clipped row-by-row instead of being dropped entirely.

```elixir
%WidgetList{
  items: [
    {%Paragraph{text: "User: Hello!"}, 1},
    {%Markdown{content: "**Bot:** Hi there!\n\nHow can I help?"}, 4},
    {%Paragraph{text: "User: What is Elixir?"}, 1}
  ],
  selected: 1,
  highlight_style: %Style{fg: :yellow},
  scroll_offset: 0,
  block: %Block{title: "Chat", borders: [:all]}
}
```

### SlashCommands

Command palette with fuzzy search. Renders a scrollable list of `SlashCommands.Command` structs filtered by the current input.

```elixir
alias ExRatatui.Widgets.SlashCommands
alias ExRatatui.Widgets.SlashCommands.Command

%SlashCommands{
  commands: [
    %Command{name: "help", description: "Show help"},
    %Command{name: "quit", description: "Exit the app"}
  ],
  input: "he",
  selected: 0,
  block: %Block{title: "Commands", borders: [:all]}
}
```

## Examples

  * [`examples/widget_showcase.exs`](https://github.com/mcass19/ex_ratatui/blob/main/examples/widget_showcase.exs) — interactive showcase of tabs, progress bars, checkboxes, text input, and scrollable logs
  * [`examples/chat_interface.exs`](https://github.com/mcass19/ex_ratatui/blob/main/examples/chat_interface.exs) — AI chat interface demonstrating markdown, textarea, throbber, popup, and slash commands
  * [`examples/task_manager/`](https://github.com/mcass19/ex_ratatui/tree/main/examples/task_manager) — full CRUD app using table, tabs, scrollbar, line gauge, and block compositions

## Related

  * [Callback Runtime](callback_runtime.md) — OTP-style callbacks
  * [Reducer Runtime](reducer_runtime.md) — Elm-style commands and subscriptions
  * [Running TUIs over SSH](ssh_transport.md) — SSH transport
  * [Running TUIs over Erlang Distribution](distributed_transport.md) — distribution transport
