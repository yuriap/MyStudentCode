  Unit UGauss;
  interface
  Const N=10;
  Type
    LeftPartType = array [1..N,1..N] of real;
    RightIncPartType = array [1..N] of real;
  PROCEDURE Gauss(a:LeftPartType;b:RightIncPartType;var x:RightIncPartType;
   n :integer;var Ierr:integer);
 implementation
  PROCEDURE Gauss(a:LeftPartType;b:RightIncPartType;var x:RightIncPartType;
  n :integer;var Ierr:integer);
  {решение системы линейных уравнений}
  Label 160;
  Var
         WorkA                                  :LeftPartType;
         IX,IY                                  :array [1..10] of integer;
         y,z                                    :real;
         i,j,k,l,m,line,column,cl,cc,cl1,
         cc1,N1,N2,t,r,s,w                      :integer;
  Begin
        Ierr:=0;
        N1:=N-1;
        N2:=N-2;
       For i:=1 to N do
       begin
          For j:=1 to N do
          begin
             WorkA[i,j]:=A[i,j];
          end;
          IY[i]:=i;
          IX[i]:=i;
          X[i]:=B[i];
       end;
        For cl:=1 to N1 do
        begin
        cc:=cl;
        line:=cl;
        column:=cc;
        For i:=cl to N do
           begin
           For j:=cc to N do
              begin
              If Abs(WorkA[line,column]) < Abs(WorkA[i,j]) then
                 begin
                 line:=i;
                 column:=j;
                 end;
              end;
           end;
        if cl <> line then
           begin
           For j:=cc to N do
              begin
              y:=WorkA[line,j];
              WorkA[line,j]:=WorkA[cl,j];
              WorkA[cl,j]:=y;
              end;
           z:=X[line];
           X[line]:=X[cl];
           X[cl]:=z;
           k:=IY[line];
           IY[line]:=IY[cl];
           IY[cl]:=k;
           end;
        if cc <> column then
           begin
           For i:=1 to N do
              begin
              y:=WorkA[i,column];
              WorkA[i,column]:=WorkA[i,cl];
              WorkA[i,cl]:=y;
              end;
           k:=IX[column];
           IX[column]:=IX[cc];
           IX[cc]:=k;
           end;
        if  Abs(WorkA[cl,cc]) < 1.E-20 then
           begin
           Ierr:=IY[cl];
           Goto 160;
           end;
        cl1:=cl+1;
        cc1:=cc+1;
        For j:=cc1 to N do
           begin
           WorkA[cl,j]:=WorkA[cl,j]/WorkA[cl,cc];
           end;
        X[cl]:=X[cl]/WorkA[cl,cc];
        WorkA[cl,cc]:=1.0;
        For i:=cl1 to N do
           begin
           z:=WorkA[i,cc];
           WorkA[i,cc]:=0.0;
           For j:=cc1 to N do
              begin
              WorkA[i,j]:=WorkA[i,j]-WorkA[cl,j]*z;
              end;
           X[i]:=X[i]-X[cl]*z;
           end;
       end;
        if  Abs(WorkA[N,N]) < 1.E-20 then {знак отношения наоборот}
           begin
           Ierr:=-IY[N];
           Goto 160;
           end;
        X[N]:=X[N]/WorkA[N,N];
        For k:=0 to N2 do
           begin
           j:=N-k;
           m:=k+1;
           For l:=m to N1 do
              begin
              i:=N-l;
              z:=WorkA[i,j];
              X[i]:=X[i]-X[j]*z;
              end;
           end;
        For i:=1 to N do
           begin
           WorkA[i,1]:=X[i];
           end;
        For i:=1 to N do
           begin
           k:=IX[i];
           X[k]:=WorkA[i,1];
           end;
  160:
  End;
 begin
 end.