module d_cache (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    //axi interface
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok 
);
    //Cache ����
    
    //Cache ʵ�ʴ洢 ��·������
    reg                 cache_valid_1 [255 : 0];
    reg                 cache_dirty_1 [255 : 0];
    reg [21:0]          cache_tag_1   [255 : 0];
    reg [31:0]          cache_block_1 [255 : 0];
    
    reg                 cache_valid_2 [255 : 0];
    reg                 cache_dirty_2 [255 : 0];
    reg [21:0]          cache_tag_2   [255 : 0];
    reg [31:0]          cache_block_2 [255 : 0];
    
    reg                 cache_valid_3 [255 : 0];
    reg                 cache_dirty_3 [255 : 0];
    reg [21:0]          cache_tag_3   [255 : 0];
    reg [31:0]          cache_block_3 [255 : 0];
    
    reg                 cache_valid_4 [255 : 0];
    reg                 cache_dirty_4 [255 : 0];
    reg [21:0]          cache_tag_4   [255 : 0];
    reg [31:0]          cache_block_4 [255 : 0];
    
    //LRU��
    reg [1:0] LRU_1 [255 : 0];
    reg [1:0] LRU_2 [255 : 0];
    reg [1:0] LRU_3 [255 : 0];
    reg [1:0] LRU_4 [255 : 0];
    
    //��ַ�ֽ�
    wire [1:0] offset;
    wire [7:0] index;
    wire [21:0] tag;
    
    assign offset = cpu_data_addr[1 : 0];
    assign index = cpu_data_addr[9 : 2];
    assign tag = cpu_data_addr[31 : 10];

    //���� Cache line
    wire c_valid_1;
    wire c_dirty_1;
    wire [21:0] c_tag_1;
    wire [31:0] c_block_1;
    assign c_valid_1 = cache_valid_1[index];
    assign c_tag_1   = cache_tag_1  [index];
    assign c_block_1 = cache_block_1[index];
    assign c_dirty_1 = cache_dirty_1[index];
    
    wire c_valid_2;
    wire c_dirty_2;
    wire [21:0] c_tag_2;
    wire [31:0] c_block_2;
    assign c_valid_2 = cache_valid_2[index];
    assign c_tag_2   = cache_tag_2  [index];
    assign c_block_2 = cache_block_2[index];
    assign c_dirty_2 = cache_dirty_2[index];
    
    wire c_valid_3;
    wire c_dirty_3;
    wire [21:0] c_tag_3;
    wire [31:0] c_block_3;
    assign c_valid_3 = cache_valid_3[index];
    assign c_tag_3   = cache_tag_3  [index];
    assign c_block_3 = cache_block_3[index];
    assign c_dirty_3 = cache_dirty_3[index];
       
    wire c_valid_4;
    wire c_dirty_4;
    wire [21:0] c_tag_4;
    wire [31:0] c_block_4;
    assign c_valid_4 = cache_valid_4[index];
    assign c_tag_4   = cache_tag_4  [index];
    assign c_block_4 = cache_block_4[index];
    assign c_dirty_4 = cache_dirty_4[index];


    //�ֱ��ж�����
    wire hit_1, miss_1,hit_2,miss_2,hit_3,miss_3,hit_4,miss_4;
    assign hit_1 = c_valid_1 & (c_tag_1 == tag);  //��ЧλΪ1�ұ����ͬ
    assign miss_1 = ~hit_1;
    
    assign hit_2 = c_valid_2 & (c_tag_2 == tag);  //��ЧλΪ1�ұ����ͬ
    assign miss_2 = ~hit_2;
    
    assign hit_3 = c_valid_3 & (c_tag_3 == tag);  //��ЧλΪ1�ұ����ͬ
    assign miss_3 = ~hit_3;
    
    assign hit_4 = c_valid_4 & (c_tag_4 == tag);  //��ЧλΪ1�ұ����ͬ
    assign miss_4 = ~hit_4;
    
    //�ж����к�ȱʧ
    wire hit,miss;
    assign hit = hit_1 | hit_2 | hit_3 | hit_4;
    assign miss = ~ hit;
    
    
    //�滻��ĵ�ַ����λ
    reg [1:0] LRU_addr;//�滻��ĵ�ַ
    reg dirty;
    reg cpu_write;
    
    //�޸�LRU��
    always @(posedge cpu_data_req)begin
        cpu_write<=cpu_data_wr;
        if(miss==1)begin
            //����LRUѡ��һ���滻��
            if(LRU_1[index]==2'b00)begin
                //ȡ��һ����
                LRU_addr<=2'b00;
                dirty<=cache_dirty_1[index];
                //��λ������
                LRU_1[index]<=2'b11;
                
                if(LRU_2[index]==2'b00)begin
                    LRU_2[index]<=2'b00;
                end else begin
                    LRU_2[index]<=LRU_2[index]-1;
                end
                
                if(LRU_3[index]==2'b00)begin
                    LRU_3[index]<=2'b00;
                end else begin
                    LRU_3[index]<=LRU_3[index]-1;
                end
                
                if(LRU_4[index]==2'b00)begin
                    LRU_4[index]<=2'b00;
                end else begin
                    LRU_4[index]<=LRU_4[index]-1;
                end
                
            end else if (LRU_1[index]!=2'b00 & LRU_2[index]==2'b00)begin
                //ȡ�ڶ�����
                LRU_addr<=2'b01;
                dirty<=cache_dirty_2[index];
                //��λ������
                LRU_2[index]<=2'b11;
                
                if(LRU_1[index]==2'b00)begin
                    LRU_1[index]<=2'b00;
                end else begin
                    LRU_1[index]<=LRU_1[index]-1;
                end
                
                if(LRU_3[index]==2'b00)begin
                    LRU_3[index]<=2'b00;
                end else begin
                    LRU_3[index]<=LRU_3[index]-1;
                end
                
                if(LRU_4[index]==2'b00)begin
                    LRU_4[index]<=2'b00;
                end else begin
                    LRU_4[index]<=LRU_4[index]-1;
                end
                
            end else if (LRU_1[index]!=2'b00 & LRU_2[index]!=2'b00 & LRU_3[index]==2'b00 )begin
                //ȡ��������
                LRU_addr<=2'b10;
                dirty<=cache_dirty_3[index];
                //��λ������
                LRU_3[index]<=2'b11;
                
                if(LRU_2[index]==2'b00)begin
                    LRU_2[index]<=2'b00;
                end else begin
                    LRU_2[index]<=LRU_2[index]-1;
                end
                
                if(LRU_1[index]==2'b00)begin
                    LRU_1[index]<=2'b00;
                end else begin
                    LRU_1[index]<=LRU_1[index]-1;
                end
                
                if(LRU_4[index]==2'b00)begin
                    LRU_4[index]<=2'b00;
                end else begin
                    LRU_4[index]<=LRU_4[index]-1;
                end
            end else begin
                //ȡ���ĸ���
                LRU_addr<=2'b11;
                dirty<=cache_dirty_4[index];
                //��λ������
                LRU_4[index]<=2'b11;
                
                if(LRU_2[index]==2'b00)begin
                    LRU_2[index]<=2'b00;
                end else begin
                    LRU_2[index]<=LRU_2[index]-1;
                end
                
                if(LRU_3[index]==2'b00)begin
                    LRU_3[index]<=2'b00;
                end else begin
                    LRU_3[index]<=LRU_3[index]-1;
                end
                
                if(LRU_1[index]==2'b00)begin
                    LRU_1[index]<=2'b00;
                end else begin
                    LRU_1[index]<=LRU_1[index]-1;
                end
            end
        end else begin
            //���к�Ĳ���
            if(hit_1==1)begin
                //�޸ı��Լ���ļ���������һ��
                if(LRU_2[index]>LRU_1[index])begin
                    LRU_2[index]<=LRU_2[index]-1;
                end else begin
                    LRU_2[index]<=LRU_2[index];
                end
                
                if(LRU_3[index]>LRU_1[index])begin
                    LRU_3[index]<=LRU_3[index]-1;
                end else begin
                    LRU_3[index]<=LRU_3[index];
                end
                
                if(LRU_4[index]>LRU_1[index])begin
                    LRU_4[index]<=LRU_4[index]-1;
                end else begin
                    LRU_4[index]<=LRU_4[index];
                end
                
                LRU_1[index]<=2'b11;
            end 
            if(hit_2==1)begin
            //�޸ı��Լ���ļ���������һ��
                if(LRU_1[index]>LRU_2[index])begin
                    LRU_1[index]<=LRU_1[index]-1;
                end else begin
                    LRU_1[index]<=LRU_1[index];
                end
                
                if(LRU_3[index]>LRU_2[index])begin
                    LRU_3[index]<=LRU_3[index]-1;
                end else begin
                    LRU_3[index]<=LRU_3[index];
                end
                
                if(LRU_4[index]>LRU_2[index])begin
                    LRU_4[index]<=LRU_4[index]-1;
                end else begin
                    LRU_4[index]<=LRU_4[index];
                end
                
                LRU_2[index]<=2'b11;
            end 
            if(hit_3==1)begin
            //�޸ı��Լ���ļ���������һ��
                if(LRU_2[index]>LRU_3[index])begin
                    LRU_2[index]<=LRU_2[index]-1;
                end else begin
                    LRU_2[index]<=LRU_2[index];
                end
                
                if(LRU_1[index]>LRU_3[index])begin
                    LRU_1[index]<=LRU_1[index]-1;
                end else begin
                    LRU_1[index]<=LRU_1[index];
                end
                
                if(LRU_4[index]>LRU_3[index])begin
                    LRU_4[index]<=LRU_4[index]-1;
                end else begin
                    LRU_4[index]<=LRU_4[index];
                end
                
                LRU_3[index]<=2'b11;
            end 
            if(hit_4==1)begin
            //�޸ı��Լ���ļ���������һ��
                if(LRU_2[index]>LRU_4[index])begin
                    LRU_2[index]<=LRU_2[index]-1;
                end else begin
                    LRU_2[index]<=LRU_2[index];
                end
                
                if(LRU_3[index]>LRU_4[index])begin
                    LRU_3[index]<=LRU_3[index]-1;
                end else begin
                    LRU_3[index]<=LRU_3[index];
                end
                
                if(LRU_1[index]>LRU_4[index])begin
                    LRU_1[index]<=LRU_1[index]-1;
                end else begin
                    LRU_1[index]<=LRU_1[index];
                end
                
                LRU_4[index]<=2'b11;
            end
        end
    end
    reg [31:0] change_addr;
    reg [31:0] change_data;
    always @(*) begin
        case(LRU_addr)
           2'b00:begin
               change_addr<={c_tag_1,index,offset};
               change_data<=c_block_1;
           end
           2'b01:begin
               change_addr<={c_tag_2,index,offset};
               change_data<=c_block_2;
           end
           2'b10:begin
               change_addr<={c_tag_3,index,offset};
               change_data<=c_block_3;
           end
           2'b11:begin
               change_addr<={c_tag_4,index,offset};
               change_data<=c_block_4;
           end
           default:begin
               change_addr<={c_tag_1,index,offset};
               change_data<=c_block_1;
           end
        endcase
    end
    
    //��д�ź�
    reg read, write;
    //FSM
    parameter H = 2'b00, NHD = 2'b01, NHND = 2'b10; //H����Ҫ��д�洢����NHD��Ҫд�Ͷ���NHNDֻ��Ҫ��
    reg [1:0] state;
    wire [31:0] mem_addr;
    wire write_en;
    always @(posedge clk) begin
        if(rst) begin
            state <= H;
        end
        else begin
            case(state)
                H: begin
                    if((cpu_data_req & miss))begin
                        if(dirty)begin
                            state <= NHD;
                            write <= 1'b1;
                            read <= 1'b0;
                        end else begin
                            state <= NHND;
                            write <= 1'b0;
                            read <= 1'b1;
                        end
                        
                    end else begin
                        state <= H;
                        write <= 1'b0;
                        read <= 1'b1;
                    end
                end
                NHD:begin 
                    state <= cache_data_data_ok ? NHND : NHD;
                    write <= cache_data_data_ok ? 1'b0: 1'b1;
                    read <= cache_data_data_ok ? 1'b1 : 1'b0;
                end    
                NHND:begin
                    state <= cache_data_data_ok ? H : NHND;
                    write <= 1'b0;
                    read <= 1'b1;
                end
                default:begin 
                    state<=state;
                    write <= write;
                    read <= read;
                end
            endcase
        end
    end
    
    wire write_finish;
    wire write_req;     
    reg waddr_rcv;  
    //���д�ڴ�
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     write & cache_data_req & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 : waddr_rcv;
    end
    assign write_req = state==NHD;
    assign write_finish = write & cache_data_data_ok;
    
       //д�ڴ���Ϻ���ڴ�
    //���ڴ�
    wire read_req;      //һ�ζ����񣬴ӿ�ʼ������
    reg addr_rcv;       //��ַ���ܳɹ�������
    wire read_finish;   //���ݽ��ܳɹ�
    
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    read & cache_data_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = (state==NHND);
    assign read_finish = read & cache_data_data_ok;
    
    //���ӵ�ַ

    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;
    assign cache_data_wr    = write_en;//��鱻�滻���ڲ�д�ڴ�
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = mem_addr;//��ַʱ��
    assign cache_data_wdata = change_data;//Ҫд�������
    
 
    

    //�����ַ�е�tag, index����ֹaddr�����ı�
    reg [21:0] tag_save;
    reg [7:0] index_save;
    reg write_cpu;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
        write_cpu <= rst ? 0 :
                      cpu_data_req ? cpu_data_wr : write_cpu;              
    end
    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<256; t=t+1) begin   //��ʼʱ�ÿ���Ч
                cache_valid_1[t] <= 0;
                cache_valid_2[t] <= 0;
                cache_valid_3[t] <= 0;
                cache_valid_4[t] <= 0;
                cache_dirty_1[t] <= 0;
                cache_dirty_2[t] <= 0;
                cache_dirty_3[t] <= 0;
                cache_dirty_4[t] <= 0;
                LRU_1[t] <= 2'b00;
                LRU_2[t] <= 2'b00;
                LRU_3[t] <= 2'b00;
                LRU_4[t] <= 2'b00;
                
            end
        end
        else begin
            if(read_finish) begin //ȱʧ���Ѿ��������
                if(cpu_data_wr)begin
                   case (LRU_addr)
                    2'b00:begin
                        //д���һ����
                        cache_valid_1[index_save] <= 1'b1;
                        cache_dirty_1[index_save] <= 1'b1;               
                        cache_tag_1  [index_save] <= tag_save;
                        cache_block_1[index_save] <= cpu_data_wdata; 
                    end    
                    2'b01:begin
                        //д��ڶ�����
                        cache_valid_2[index_save] <= 1'b1; 
                        cache_dirty_2[index_save] <= 1'b1;              
                        cache_tag_2  [index_save] <= tag_save;
                        cache_block_2[index_save] <= cpu_data_wdata; 
                    end
                    2'b10:begin
                        //д���������
                        cache_valid_3[index_save] <= 1'b1;
                        cache_dirty_3[index_save] <= 1'b1;               
                        cache_tag_3  [index_save] <= tag_save;
                        cache_block_3[index_save] <= cpu_data_wdata; 
                    end
                    2'b11:begin
                        //д����ĸ���
                        cache_valid_4[index_save] <= 1'b1; 
                        cache_dirty_4[index_save] <= 1'b1;              
                        cache_tag_4  [index_save] <= tag_save;
                        cache_block_4[index_save] <= cpu_data_wdata; 
                    end
                   endcase
                end else begin
                    case (LRU_addr)
                    2'b00:begin
                        //д���һ����
                        cache_valid_1[index_save] <= 1'b1;
                        cache_dirty_1[index_save] <= 1'b0;               
                        cache_tag_1  [index_save] <= tag_save;
                        cache_block_1[index_save] <= cache_data_rdata; 
                    end    
                    2'b01:begin
                        //д��ڶ�����
                        cache_valid_2[index_save] <= 1'b1; 
                        cache_dirty_2[index_save] <= 1'b0;              
                        cache_tag_2  [index_save] <= tag_save;
                        cache_block_2[index_save] <= cache_data_rdata; 
                    end
                    2'b10:begin
                        //д���������
                        cache_valid_3[index_save] <= 1'b1;
                        cache_dirty_3[index_save] <= 1'b0;               
                        cache_tag_3  [index_save] <= tag_save;
                        cache_block_3[index_save] <= cache_data_rdata; 
                    end
                    2'b11:begin
                        //д����ĸ���
                        cache_valid_4[index_save] <= 1'b1; 
                        cache_dirty_4[index_save] <= 1'b0;              
                        cache_tag_4  [index_save] <= tag_save;
                        cache_block_4[index_save] <= cache_data_rdata; 
                    end
                   endcase
                end       
            end
            else if(cpu_data_wr & cpu_data_req & hit) begin   //��д����
                if(hit_1)begin
                    cache_block_1[index] <= cpu_data_wdata;
                    cache_dirty_1[index] <= 1'b1;
                end
                if(hit_2)begin
                    cache_block_2[index] <= cpu_data_wdata;
                    cache_dirty_2[index] <= 1'b1;
                end
                if(hit_3)begin
                    cache_block_3[index] <= cpu_data_wdata;
                    cache_dirty_3[index] <= 1'b1;
                end
                if(hit_4)begin
                    cache_block_4[index] <= cpu_data_wdata;
                    cache_dirty_4[index] <= 1'b1;
                end                 
            end
        end
    end
    
    //output to mips core
    assign cpu_data_rdata   = hit_1 ? c_block_1 : (hit_2 ? c_block_2 : (hit_3 ? c_block_3 : (hit_4 ? c_block_4 :cache_data_rdata)));
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | read_finish;




endmodule