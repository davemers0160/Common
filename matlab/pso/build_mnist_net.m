function build_dfd_net_rw(filename, pso_member, net_description)

    con_idx = 1;
    fc_idx = 1;
    bn_idx = 1;
    act_idx = 1;
    mp_idx = 1;
    end_cnt = 1;
    
    file_id = fopen(filename,'w');
    
    fprintf(file_id, '// Auto generated c++ header file for PSO testing\n');
    fprintf(file_id, '// Iteration Number: %d\n', pso_member.iteration);
    fprintf(file_id, '// Population Number: %d\n\n', pso_member.number);

    % print the net headers
    fprintf(file_id, '#ifndef NET_DEFINITION_H\n');
    fprintf(file_id, '#define NET_DEFINITION_H\n\n');
    fprintf(file_id, '#include <cstdint>\n');
    fprintf(file_id, '#include <string>\n\n');
    
    fprintf(file_id, '#include "dlib/dnn.h"\n');
    fprintf(file_id, '#include "dlib/dnn/core.h"\n\n');
    
    fprintf(file_id, '#include "dlib_elu.h"\n');
    fprintf(file_id, '#include "dlib_srelu.h"\n\n');
    
%     fprintf(file_id, 'extern const uint32_t img_depth = %d;\n',input_type(pso_member.input,1));
%     fprintf(file_id, 'extern const uint32_t secondary = %d;\n',input_type(pso_member.input,2));
%     fprintf(file_id, 'extern const std::string train_inputfile = "%s";\n',input_files{pso_member.input_file}{1});
%     fprintf(file_id, 'extern const std::string test_inputfile = "%s";\n',input_files{pso_member.input_file}{2});
    fprintf(file_id, 'extern const std::string version = "%s";\n', strcat('pso_',num2str(pso_member.number,'%02d_'),num2str(pso_member.iteration,'%02d')));
%     fprintf(file_id, 'extern const std::vector<std::pair<uint64_t, uint64_t>> crop_sizes = {{%d, %d}, {368, 400}};\n',pso_member.crop_size*crop_scale(1),pso_member.crop_size*crop_scale(2));
%     fprintf(file_id, 'extern const uint64_t num_crops = %d;\n',crop_num(pso_member.crop_size));
%     fprintf(file_id, 'extern const std::pair<uint32_t, uint32_t> crop_scale(1, 1);\n\n');
%     
    fprintf(file_id, '//-----------------------------------------------------------------\n\n');
    fprintf(file_id, 'typedef struct{\n    uint32_t iteration;\n    uint32_t pop_num;\n} pso_struct;\n');
    fprintf(file_id, 'pso_struct pso_info = {%d, %d};\n\n', pso_member.iteration, pso_member.number);

%     fprintf(file_id, '//-----------------------------------------------------------------\n\n');
%     fprintf(file_id, 'template <long num_filters, typename SUBNET> using con2d = dlib::con<num_filters, 2, 2, 2, 2, SUBNET>;\n');
%     fprintf(file_id, 'template <long num_filters, typename SUBNET> using con33d33 = dlib::con<num_filters, 3, 3, 3, 3, SUBNET>;\n');
%     fprintf(file_id, 'template <long num_filters, typename SUBNET> using con32d32 = dlib::con<num_filters, 3, 2, 3, 2, SUBNET>;\n');
%     fprintf(file_id, 'template <long num_filters, typename SUBNET> using con21d21 = dlib::con<num_filters, 2, 1, 2, 1, SUBNET>;\n\n');
% 
%     fprintf(file_id, 'template <long num_filters, typename SUBNET> using cont2u = dlib::cont<num_filters, 2, 2, 2, 2, SUBNET>;\n\n');
% 
%     fprintf(file_id, 'template <typename SUBNET> using DTO_0 = dlib::add_tag_layer<200, SUBNET>;\n');
%     fprintf(file_id, 'template <typename SUBNET> using DTI_0 = dlib::add_tag_layer<201, SUBNET>;\n');
%     fprintf(file_id, 'template <typename SUBNET> using DTO_1 = dlib::add_tag_layer<202, SUBNET>;\n');
%     fprintf(file_id, 'template <typename SUBNET> using DTI_1 = dlib::add_tag_layer<203, SUBNET>;\n');
%     fprintf(file_id, 'template <typename SUBNET> using DTO_2 = dlib::add_tag_layer<204, SUBNET>;\n');
%     fprintf(file_id, 'template <typename SUBNET> using DTI_2 = dlib::add_tag_layer<205, SUBNET>;\n\n');

    fprintf(file_id, '//-----------------------------------------------------------------\n\n');
    fprintf(file_id, 'using net_type = dlib::loss_multiclass_log<\n');

    for idx=1:numel(net_description.net_structure)

        if(strcmp(net_description.net_structure{idx}, 'con'))
            fprintf(file_id, '    dlib::con<%d, %d, %d, 1, 1, \n', pso_member.con(pso_member.con_map(con_idx),1),2*pso_member.con(pso_member.con_map(con_idx),2)+1,2*pso_member.con(pso_member.con_map(con_idx),3)+1); 
            con_idx = con_idx + 1;
            
        elseif(strcmp(net_description.net_structure{idx}, 'fc'))
            fprintf(file_id, '    dlib::fc<%d, \n', pso_member.fc(pso_member.fc_map(fc_idx),1)); 
            fc_idx = fc_idx + 1;
            
        elseif(strcmp(net_description.net_structure{idx}, 'act'))
            fprintf(file_id, '    %s', net_description.activations{pso_member.act(act_idx)});
            act_idx = act_idx + 1;
            
        elseif(strcmp(net_description.net_structure{idx}, 'bn'))
            if(pso_member.bn(bn_idx) == 1)
                fprintf(file_id, '    dlib::bn_con<');
            else
                end_cnt = end_cnt + 1;
            end
            bn_idx = bn_idx + 1;
            
        elseif(strcmp(net_description.net_structure{idx}, 'mp'))  
            fprintf(file_id, '    dlib::max_pool<2, 2, 2, 2,');
            mp_idx = mp_idx + 1;
            
%         elseif(strcmp(net_description.net_structure{idx}, 'cond'))
%             %fprintf(file_id, '    %s%d,', net_description.cond{cond_order(pso_member.cond,cond_idx)}, pso_member.con(con_idx,1)); 
%             fprintf(file_id, '    %s%d,', net_description.cond{cond_idx}, pso_member.con(pso_member.con_map(con_idx),1)); 
%             cond_idx = cond_idx + 1;
%             con_idx = con_idx + 1;
%             
%         elseif(strcmp(net_description.net_structure{idx}, 'cont'))
%             fprintf(file_id, '    dlib::cont<%d, %d, %d, 2, 2, \n', pso_member.con(pso_member.con_map(con_idx),1),2*pso_member.con(pso_member.con_map(con_idx),2)+1,2*pso_member.con(pso_member.con_map(con_idx),3)+1);
%             con_idx = con_idx + 1;
%             
%         elseif(strcmp(net_description.net_structure{idx}, 'cont2u'))
%             fprintf(file_id, '    dlib::cont<%d, 2, 2, 2, 2, \n', pso_member.con(pso_member.con_map(con_idx),1));
%             con_idx = con_idx + 1;
%             
%         elseif(strcmp(net_description.net_structure{idx}, 'concat'))
%             fprintf(file_id, '    %s\n', net_description.concats{concat_idx}); 
%             concat_idx = concat_idx + 1;      
%             
%         elseif(strcmp(net_description.net_structure{idx}, 'add_prev1'))
%             fprintf(file_id, '    dlib::add_prev1<');
%         elseif(strcmp(net_description.net_structure{idx}, 'tag1'))
%             fprintf(file_id, '    dlib::tag1<');
%         elseif(strcmp(net_description.net_structure{idx}, 'tags'))
%             fprintf(file_id, '    %s',net_description.tags{tag_idx});
%             tag_idx = tag_idx + 1;
            
        elseif(strcmp(net_description.net_structure{idx}, 'input'))
            fprintf(file_id, '    dlib::input<dlib::matrix<unsigned char>>\n');         
        end    

    end
    
    e = repmat('>',1,idx-end_cnt+1);
    fprintf(file_id, '    %s;\n\n',e);

    fprintf(file_id, '//-----------------------------------------------------------------\n\n');

    fprintf(file_id, 'inline std::ostream& operator<< (std::ostream& out, const pso_struct& item)\n{\n');
    fprintf(file_id, '    out << "------------------------------------------------------------------" << std::endl;\n');
    fprintf(file_id, '    out << "PSO Info: " << std::endl;\n');
    fprintf(file_id, '    out << "  Iteration: " << item.iteration << std::endl;\n');
    fprintf(file_id, '    out << "  Population Number: " << item.pop_num << std::endl;\n');
    fprintf(file_id, '    out << "------------------------------------------------------------------" << std::endl;\n');
    fprintf(file_id, '    return out;\n}\n\n');

    fprintf(file_id, '#endif \n\n');
    
    fclose(file_id); 

end