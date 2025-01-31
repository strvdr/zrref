# Interactive Matrix Row Reduction Calculator

A Zig program that performs Gaussian elimination (row reduction) on matrices with an interactive, color-coded interface.

## Features

- Interactive command-line interface
- Step-by-step visualization of the row reduction process
- Color-coded output for better readability
- Support for arbitrary-sized matrices
- Real-time display of matrix transformations
- Detailed progress messages for each operation

## Prerequisites

To compile the binary, you need to have Zig installed on your system. This program has been tested with Zig 0.14.0. You can also check "releases" to see if there's a binary for your OS. 

## Installation

1. Clone or download the source files:
   ```bash
   git clone https://github.com/strvdr/zrref.git
   cd zrref
   ```

2. Compile the program:
   ```bash
   zig build   
   ```

## Usage

1. Run the program:
   ```bash
   ./zig-out/bin/zrref
   ```
or:
   ```bash
    cd zig-out/bin
   ./zrref
   ```

2. Follow the prompts:
   - Enter the number of rows
   - Enter the number of columns
   - Input each matrix value when prompted

3. Watch as the program:
   - Displays the original matrix
   - Shows each step of the row reduction process
   - Presents the final reduced matrix

4. Press Enter to exit when finished

## Example

Here's a sample run for a 2×3 matrix:

```
Welcome to the Matrix Row Reduction Calculator!
This program will help you perform Gaussian elimination on a matrix.

Enter number of rows: 2
Enter number of columns: 3

Enter matrix values row by row:
Enter value for position (1,1): 1
Enter value for position (1,2): 2
Enter value for position (1,3): 3
Enter value for position (2,1): 4
Enter value for position (2,2): 5
Enter value for position (2,3): 6

Original matrix:
│    1.000     2.000     3.000 │
│    4.000     5.000     6.000 │

Starting row reduction...
[Operations will be displayed here]

Row reduction complete!
```

## Color Coding

- Blue: Zero values
- Cyan: Row swap operations
- Magenta: Row scaling operations
- Green: Row elimination operations
- Yellow: Status messages
- Bold: Headers and important information

## Files

- `matrix.zig`: Main program file
- `test.zig`: Test suite for verifying functionality

## Running Tests

To run the test suite:
```bash
zig test test.zig
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.
