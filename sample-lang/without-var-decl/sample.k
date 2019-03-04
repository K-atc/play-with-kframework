module SAMPLE
    imports SAMPLE-SYNTAX
    imports DOMAINS

    syntax KResult ::= Int

    configuration <T color="yellow">
                  <k color="green"> $PGM:Pgm </k> // `krun` holds givn program in $PGM
                  <state color="red"> .Map </state> // Initial memory is blank
                </T>

    // Exp
    rule <k> X:Id => I ...</k> <state>... X |-> I ...</state>
    rule I1:Int + I2:Int => I1 +Int I2

    // Stmt
    rule <k> X = I:Int; => . ...</k> <state>... .Map => (X |-> I) ...</state> // assignments without variable decalation
    rule S1:Stmt S2:Stmt => S1 ~> S2  [structural]
endmodule

module SAMPLE-SYNTAX
    imports DOMAINS-SYNTAX // Import sorts 'Int', 'Id'

    syntax Val  ::= Int | Id
    syntax AExp ::= Val
                  | AExp "+" AExp           [left, strict]
    syntax Stmt ::= Id "=" AExp ";"         [strict(2)]
                  > Stmt Stmt               [left]
    syntax Pgm  ::= Stmt
endmodule