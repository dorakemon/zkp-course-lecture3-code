pragma circom 2.0.0;

// 与えられた入力in0とin1が等しくないことの判定
template NonEqual(){
    signal input in0;
    signal input in1;
    signal inv;
    inv <-- 1/ (in0 - in1);
    inv*(in0 - in1) === 1;
}

// n = 9なら
// inに入力された配列の中で，同じ値がないことの判定
// loopの例 (i,j) = (1,0), (2,0), (2,1)..., (8,7)
template Distinct(n) {
    signal input in[n];
    component nonEqual[n][n];
    for(var i = 0; i < n; i++){
        for(var j = 0; j < i; j++){
            nonEqual[i][j] = NonEqual();
            nonEqual[i][j].in0 <== in[i];
            nonEqual[i][j].in1 <== in[j];
        }
    }
}

// Enforce that 0 <= in < 16
// inに入力された値が，0<=in<=15を満たすことの判定
template Bits4(){
    signal input in;
    signal bits[4];
    var bitsum = 0;
    for (var i = 0; i < 4; i++) {
        bits[i] <-- (in >> i) & 1;
        bits[i] * (bits[i] - 1) === 0;
        bitsum = bitsum + 2 ** i * bits[i];
    }
    bitsum === in;
}

// Enforce that 1 <= in <= 9
// inに入力された値が，1<=in<=9を満たすことの判定
template OneToNine() {
    signal input in;
    component lowerBound = Bits4();
    component upperBound = Bits4();
    lowerBound.in <== in - 1;
    upperBound.in <== in + 6;
}

template Sudoku(n) {
    // 答え
    // solution is a 2D array: indices are (row_i, col_i)
    signal input solution[n][n];
    // 問題
    // puzzle is the same, but a zero indicates a blank
    signal input puzzle[n][n];

    component distinct[n];
    component inRange[n][n];

    // パズルの解答が問題のあなうめになっているかの判定
    // puzzle - solutionが0なら問題と解答が一致している
    // puzzleが0なら何か解答が必要 -> そこには任意の答えを入れれる
    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            // we could make this a component
            puzzle[row_i][col_i] * (puzzle[row_i][col_i] - solution[row_i][col_i]) === 0;
        }
    }

    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            if (row_i == 0) {
                distinct[col_i] = Distinct(n);
            }
            inRange[row_i][col_i] = OneToNine();
            inRange[row_i][col_i].in <== solution[row_i][col_i];
            distinct[col_i].in[row_i] <== solution[row_i][col_i];
        }
    }
}

component main {public[puzzle]} = Sudoku(9);

// 疑問: このtemplateが呼ばれたり実行されるタイミングは？
// 実行とかそういう概念はなく，その状態を作成する