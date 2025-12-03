// Agent aluno in project stones

// Regra recursiva para calcular XOR binário
xor(A, 0, A).
xor(0, B, B).
xor(A, B, Res) :- 
   A > 0 & B > 0 & 
   BitA = A mod 2 & 
   BitB = B mod 2 & 
   BitRes = (BitA + BitB) mod 2 & 
   NextA = A div 2 & 
   NextB = B div 2 & 
   xor(NextA, NextB, NextRes) & 
   Res = (NextRes * 2) + BitRes.

/* Initial goals */
!start.

/* Plans */

+!start : true <- 
    .print("sou a aluna helen e estou pronta").


+round(N, WhoPlays) 
   : .my_name(Me) & .term2string(Me, WhoPlays) 
   <- 
   .print("é a minha vez! Round ", N);
   //perceber apenas torres com pedras
   .findall(tower(Id, S), tower(Id, S) & S > 0, Towers);
   //analisar e jogar
   !analyze_and_play(Towers).

//se não for minha vez, não faço nada
+round(N, WhoPlays) : .my_name(Me) & .term2string(Me, MeStr) & MeStr \== WhoPlays.

/* estratégia */

+!analyze_and_play(Towers)
   <- 
   //pega estatisticas do "tabuleiro"
   !get_stats(Towers, 0, 0, 0, 0, Count1, CountGt1, MaxId, MaxStones);
   //calcula a nim sum
   !calc_nim_sum(Towers, NimSum);
   //decide torre e quantas peças remover
   !decide_move(CountGt1, Count1, MaxId, MaxStones, NimSum, Towers, MoveId, MoveRemove);
   
   .print("JOGADA: Torre ", MoveId, " removendo ", MoveRemove, " (NimSum: ", NimSum, ")");
   play(MoveId, MoveRemove).


//itera sobre as torres para contar quantas têm 1 pedra e quantas têm >1
+!get_stats([], C1, CG1, MID, MS, C1, CG1, MID, MS).
+!get_stats([tower(Id, S)|T], Acc1, AccGt1, CurMID, CurMS, Res1, ResGt1, ResMID, ResMS)
   <- 
   if (S == 1) { NAcc1 = Acc1 + 1; NAccGt1 = AccGt1; }
   else        { NAcc1 = Acc1;     NAccGt1 = AccGt1 + 1; };
   
   if (S > CurMS) { NMID = Id; NMS = S; }
   else           { NMID = CurMID; NMS = CurMS; };
   
   !get_stats(T, NAcc1, NAccGt1, NMID, NMS, Res1, ResGt1, ResMID, ResMS).

//calcula nim sum usando a regra xor definida no início
+!calc_nim_sum([], 0).
+!calc_nim_sum([tower(_, S)|T], Res)
   <- !calc_nim_sum(T, SubRes);  // CORREÇÃO: Ponto e vírgula aqui
      ?xor(S, SubRes, Res).      // CORREÇÃO: Interrogação para consultar a regra

/* decisao movimento */

//só restam torres de tamanho 1
// deixar numero impar de torres para o oponente
+!decide_move(0, _, _, _, _, Towers, MoveId, 1)
   <- .nth(0, Towers, tower(MoveId, _)).

//apenas uma torre tem mais de uma pedra
//manipular a torre grande para deixar o total de torres=1 sendo impar
+!decide_move(1, Count1, MaxId, MaxStones, _, _, MaxId, Remove)
   <- 
   if ( (Count1 mod 2) == 0 ) { 
      //se par, tirar pedras até sobrar 1 na torre grande 
      Remove = MaxStones - 1; 
   } else { 
      //se ímpar, removemos tudo da torre grande
      Remove = MaxStones; 
   }.

//jogo normal (nimsum > 0) -> aplicar estratégia
+!decide_move(Gt1, _, _, _, NimSum, Towers, MoveId, Remove)
   : Gt1 > 1 & NimSum > 0
   <- !find_nim_move(Towers, NimSum, MoveId, Remove).

//jogo normal (nimsum == 0)
+!decide_move(Gt1, _, MaxId, _, 0, _, MaxId, 1)
   : Gt1 > 1.

//encontra qual torre deve ser reduzida para zerar o nimsum
+!find_nim_move([tower(Id, S)|T], NimSum, ResId, ResRemove)
   <- 
   ?xor(S, NimSum, Target); // Calcula quanto a torre deveria ter
   if (Target < S) {
      ResId = Id;
      ResRemove = S - Target;
   } else {
      !find_nim_move(T, NimSum, ResId, ResRemove);
   }.

{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
