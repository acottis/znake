const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

const Square = struct {
    colour: rl.struct_Color,
    apple: bool = false,

    fn init() @This() {
        return @This(){ .colour = rl.DARKGRAY };
    }
};

const Point = struct {
    x: c_int,
    y: c_int,

    fn new(x: c_int, y: c_int) @This() {
        return @This(){
            .x = x,
            .y = y,
        };
    }
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

fn Game(comptime R: comptime_int, comptime C: comptime_int) type {
    return struct {
        grid: [R][C]Square,
        snake: [R * C]Point,
        snake_len: usize = 1,
        direction: Direction,

        fn init() @This() {
            var self = @This(){
                .grid = [_][C]Square{[_]Square{Square.init()} ** C} ** R,
                .snake = [_]Point{Point.new(0, 0)} ** (R * C),
                .direction = Direction.Up,
            };

            self.snake[0] = Point.new(R / 2, C / 2);
            self.grid[2][5] = Square{ .colour = rl.RED, .apple = true };

            return self;
        }

        fn step(self: *@This()) void {
            switch (self.direction) {
                Direction.Up => {
                    self.snake[0].y = @mod(self.snake[0].y - 1, C);
                },
                Direction.Down => {
                    self.snake[0].y = @mod(self.snake[0].y + 1, C);
                },
                Direction.Left => {
                    self.snake[0].x = @mod(self.snake[0].x - 1, R);
                },
                Direction.Right => {
                    self.snake[0].x = @mod(self.snake[0].x + 1, R);
                },
            }

            const new_sqr = self.grid[@intCast(self.snake[0].x)][@intCast(self.snake[0].y)];
            if (new_sqr.apple == true) {}
        }

        fn handle_input(self: *@This()) void {
            switch (rl.GetKeyPressed()) {
                rl.KEY_W => self.direction = Direction.Up,
                rl.KEY_S => self.direction = Direction.Down,
                rl.KEY_A => self.direction = Direction.Left,
                rl.KEY_D => self.direction = Direction.Right,
                else => {},
            }
        }

        fn render(self: *const @This()) void {
            const row_len: c_int = self.grid.len;
            const col_len: c_int = self.grid[0].len;
            const sqr_width = @divTrunc(rl.GetScreenWidth(), row_len);
            const sqr_height = @divTrunc(rl.GetScreenHeight(), col_len);

            // Grid
            for (0.., self.grid) |i, row| {
                const ri: c_int = @intCast(i);
                for (0.., row) |ii, col| {
                    const ci: c_int = @intCast(ii);

                    rl.DrawRectangle(
                        sqr_width * ri,
                        sqr_height * ci,
                        sqr_width,
                        sqr_height,
                        col.colour,
                    );
                }
            }

            // Snake
            for (0..self.snake_len) |i| {
                rl.DrawRectangle(
                    sqr_width * self.snake[i].x,
                    sqr_height * self.snake[i].y,
                    sqr_width,
                    sqr_height,
                    rl.GREEN,
                );
            }
        }
    };
}

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

    var game = Game(20, 15).init();

    var frame: usize = 0;
    while (!rl.WindowShouldClose()) {
        rl.ClearBackground(rl.DARKGRAY);

        game.render();
        game.handle_input();

        if (frame == FPS / 2) {
            game.step();
            frame = 0;
        }

        rl.BeginDrawing();
        rl.EndDrawing();
        frame += 1;
    }
}
