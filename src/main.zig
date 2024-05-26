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
        direction: Direction = Direction.Up,
        pending_direction: Direction = Direction.Up,

        fn init() @This() {
            var self = @This(){
                .grid = [_][C]Square{[_]Square{Square.init()} ** C} ** R,
                .snake = [_]Point{Point.new(0, 0)} ** (R * C),
            };

            self.snake[0] = Point.new(R / 2, C / 2);
            self.grid[2][5] = Square{ .colour = rl.RED, .apple = true };
            self.grid[4][5] = Square{ .colour = rl.RED, .apple = true };

            return self;
        }

        fn move_tail(self: *@This(), current_head: Point) void {
            var i = self.snake_len - 1;
            while (i > 1) {
                self.snake[i] = self.snake[i - 1];
                i -= 1;
            }
            self.snake[1] = current_head;
        }

        fn grow_snake(self: *@This()) void {
            self.snake_len += 1;
            var i = self.snake_len - 1;
            while (i > 0) {
                self.snake[i] = self.snake[i - 1];
                i -= 1;
            }
        }

        fn step(self: *@This()) void {
            const current_head = self.snake[0];
            var head = &self.snake[0];
            switch (self.pending_direction) {
                Direction.Up => {
                    head.y = @mod(head.y - 1, C);
                },
                Direction.Down => {
                    head.y = @mod(head.y + 1, C);
                },
                Direction.Left => {
                    head.x = @mod(head.x - 1, R);
                },
                Direction.Right => {
                    head.x = @mod(head.x + 1, R);
                },
            }
            self.direction = self.pending_direction;

            const next_sqr = &self.grid[@intCast(head.x)][@intCast(head.y)];
            if (next_sqr.apple == true) {
                next_sqr.apple = false;
                next_sqr.colour = rl.DARKGRAY;
                self.grow_snake();
            }

            self.move_tail(current_head);
            std.debug.print("{any}\n", .{self.snake[0..self.snake_len]});
        }

        fn handle_input(self: *@This()) void {
            switch (rl.GetKeyPressed()) {
                rl.KEY_W => {
                    if (self.direction != Direction.Down) {
                        self.pending_direction = Direction.Up;
                    }
                },
                rl.KEY_S => {
                    if (self.direction != Direction.Up) {
                        self.pending_direction = Direction.Down;
                    }
                },
                rl.KEY_A => {
                    if (self.direction != Direction.Right) {
                        self.pending_direction = Direction.Left;
                    }
                },
                rl.KEY_D => {
                    if (self.direction != Direction.Left) {
                        self.pending_direction = Direction.Right;
                    }
                },
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

    const WINDOW_WIDTH = 800;
    const WINDOW_HEIGHT = 600;
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

        if (frame == FPS / 3) {
            game.step();
            frame = 0;
        }

        rl.BeginDrawing();
        rl.EndDrawing();
        frame += 1;
    }
}
