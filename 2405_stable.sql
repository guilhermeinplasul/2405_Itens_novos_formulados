declare
   v_usuario                     number := :p1;
   v_comando                     number := :p2;
   v_linha                       number := 0;
   v_quebra                      number;
   v_data_ini                    date := :p3;
   v_data_fim                    date := :p4; 

   cursor c_resumo is
     select pcpop.op op_mae, 
     
            (select max(a.op)
              from pcpop a, pcpopetapa b
             where a.empresa = b.empresa
               and a.op = b.op
               and b.etapa between 20 and 27
               and a.empresa = pcpop.empresa
               and a.op_principal = pcpop.op) op,
               
            
            pcpop.usuario_inc, asdusuario.nome, pcpop.data_inc inclusao, pcpopetapa.etapa, pcpetapa.descricao, pcpop.produto, f_descricao_item(pcpop.empresa, pcpop.produto, pcpop.versao) Desc_item,
            
            pcpop.quantidade
            

     
       from pcpop, pcpopetapa, asdusuario, pcpetapa, estitem
      where pcpopetapa.empresa = 1
        and pcpopetapa.etapa >= 20
        AND PCPOPETAPA.ETAPA < 30
        and (pcpopetapa.observacao like '%NOVO%'
          or pcpopetapa.observacao like '%ALTER%')
        and estitem.descricao not like '%LISA%'
        AND estitem.descricao not like '%LISO%'
        and pcpopetapa.empresa = pcpop.empresa
        and pcpopetapa.op = pcpop.op
        and pcpop.usuario_inc = asdusuario.cpf
        and pcpop.empresa = estitem.empresa
        and pcpop.produto = estitem.codigo
        and pcpop.op = pcpopetapa.op
--        and data_inc between '01.05.2020' and '25.05.2020'
        and data_inc between v_data_ini and v_data_fim
        and pcpop.situacao not in 'C'
        and pcpopetapa.empresa = pcpetapa.empresa
        and pcpopetapa.etapa = pcpetapa.codigo
  
   group by 
      pcpop.op, pcpop.op_principal, estitem.tipo_item, pcpop.empresa, pcpop.produto, pcpop.versao, pcpopetapa.etapa, asdusuario.nome, 
      pcpop.usuario_inc, pcpop.data_inc, pcpetapa.descricao, pcpop.produto, f_descricao_item(pcpop.empresa, pcpop.produto, pcpop.versao), pcpop.quantidade;  
   
   r_resumo                      c_resumo%rowtype;
begin
   --Cabeçalho Colunas
   v_linha                    := v_linha + 1;

   insert into divexpdados values (v_usuario, v_comando, v_linha, 1, 'OP MAE');
   insert into divexpdados values (v_usuario, v_comando, v_linha, 2, 'OP');   
   insert into divexpdados values (v_usuario, v_comando, v_linha, 3, 'INCLUSAO');
   insert into divexpdados values (v_usuario, v_comando, v_linha, 4, 'PRODUTO');
   insert into divexpdados values (v_usuario, v_comando, v_linha, 5, 'DESCRICAO');
--   insert into divexpdados values (v_usuario, v_comando, v_linha, 6, 'RASTREABILIDADE');
--   insert into divexpdados values (v_usuario, v_comando, v_linha, 7, 'GRAVACAO');
      
   --Itens
   open c_resumo;

   loop
      fetch c_resumo
       into r_resumo;

      exit when c_resumo%notfound;
      v_linha:= v_linha + 1;

      insert into divexpdados values (v_usuario, v_comando, v_linha, 1, r_resumo.op_mae);
      insert into divexpdados values (v_usuario, v_comando, v_linha, 2, r_resumo.op);
--      insert into divexpdados values (v_usuario, v_comando, v_linha, 2, r_resumo.usuario_inc);
      insert into divexpdados values (v_usuario, v_comando, v_linha, 3, r_resumo.inclusao);
      insert into divexpdados values (v_usuario, v_comando, v_linha, 4, r_resumo.produto);
      insert into divexpdados values (v_usuario, v_comando, v_linha, 5, r_resumo.desc_item);
--      insert into divexpdados values (v_usuario, v_comando, v_linha, 6, r_resumo.rastreabilidade);
--      insert into divexpdados values (v_usuario, v_comando, v_linha, 7, r_resumo.gravacao);
            
   end loop;

   close c_resumo;
-- commit;
end;
