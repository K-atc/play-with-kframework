module SAMPLE
    imports SAMPLE-SYNTAX
    imports DOMAINS

    syntax KResult ::= Int

    configuration <T color="yellow">
                  <k color="green"> $PGM:Pgm </k>
                  <state color="red"> .Map </state>
                </T>

    // Exp
    rule <k> X:Id => I ...</k> <state>... X |-> I ...</state>
    rule I1:Int + I2:Int => I1 +Int I2

    // Stmt
    // rule <k> X = I:Int; => . ...</k> <state>... .Map => (X |-> I) ...</state> // assignments without variable decalation
    rule <k> X = I:Int; => . ...</k> <state>... X |-> (_ => I) ...</state> // assignments with decalared variables
    rule S1:Stmt S2:Stmt => S1 ~> S2  [structural]

    // Pgm
    rule <k> int (X,Xs => Xs);_ </k> <state> Rho:Map (.Map => X|->0) </state>
        requires notBool (X in keys(Rho)) // variable declation
    rule int .Ids; S => S  [structural]
endmodule

module SAMPLE-SYNTAX
    // see [Error while compiling lambda.k](https://github.com/kframework/k/issues/22)
    imports DOMAINS-SYNTAX
    // imports ID
    // imports INT

    syntax Val ::= Int | Id
    syntax AExp  ::= Val
                    | AExp "+" AExp              [left, strict]
    syntax Stmt  ::=  Id "=" AExp ";"            [strict(2)]
                    > Stmt Stmt                  [left]
    syntax Pgm ::= "int" Ids ";" Stmt
    syntax Ids ::= List{Id,","}
endmodule