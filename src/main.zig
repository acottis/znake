const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

const grid = [4][4]Square;

const Square = struct {
    fn init() @This() {
        return @This(){};
    }
};

const Game = struct {
    grid: grid,

    fn init() @This() {
        return @This(){
            //.grid = [20]Square{[15]Square{Square.init()} ** 15} ** 20,
            .grid = [4][4]Square{
                [_]Square{Square.init()} ** 4,
                [_]Square{Square.init()} ** 4,
                [_]Square{Square.init()} ** 4,
                [_]Square{Square.init()} ** 4,
            },
        };
    }
};

pub fn main() !void {
    std.debug.print("{}\n", .{rl});

    const WINDOW_WIDTH = 799;
    const WINDOW_HEIGHT = 599;
    const FPS = 144;

    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "foo");
    rl.SetTargetFPS(FPS);

    const monitor = rl.GetCurrentMonitor();
    rl.SetWindowMaxSize(
        rl.GetMonitorWidth(monitor),
        rl.GetMonitorHeight(monitor),
    );
    rl.SetWindowMinSize(1, 1);

    const game = Game.init();

    while (!rl.WindowShouldClose()) {
        render_grid(&game);
        rl.BeginDrawing();
        rl.EndDrawing();
    }
}

fn render_grid(game: *const Game) void {
    rl.ClearBackground(rl.DARKGRAY);
    rl.DrawPixel(700, 500, rl.RED);

    const row_len: c_int = game.grid.len;
    const col_len: c_int = game.grid[0].len;
    const sqr_width = @divTrunc(rl.GetScreenWidth(), row_len);
    const sqr_height = @divTrunc(rl.GetScreenHeight(), col_len);

    for (0.., game.grid) |i, row| {
        const ri: c_int = @intCast(i);
        for (0.., row) |ii, _| {
            const ci: c_int = @intCast(ii);
            rl.DrawRectangleLines(sqr_width * ri, sqr_height * ci, sqr_width, sqr_height, rl.RED);
        }
    }
}
