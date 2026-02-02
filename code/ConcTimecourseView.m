classdef ConcTimecourseView < handle
    
    properties ( Access = private ) 
        Model
        
        ConcColors = [0.30,0.75,0.93;...
                      0.86,0.55,0.41;...
                      0.91,0.73,0.42]; % colors to plot concentrations
        FontName = "Helvetica";
    end

    properties ( Hidden )
        % Leave these properties Hidden but public to enable access for any test generated
        % with Copilot during workshop
        Axes

        % line handles
        lhDrug
        lhReceptor
        lhComplex

    end
    
    properties( Access = private )
        DataListener % listener
    end
    
    methods
        function obj = ConcTimecourseView(parent, model)

            arguments
                parent 
                model (1,1) SimulationModel
            end
            
            ax = uiaxes(parent);
            graystyle(ax);
            xlabel(ax, "Time (hours)", 'FontName',obj.FontName);
            ylabel(ax, "Concentrations (nanomole/liter)",'FontName',obj.FontName);

            obj.lhDrug = plot(ax, NaN, NaN, '-','Linewidth',2,'Color',obj.ConcColors(1,:));
            hold(ax,'on');
            obj.lhReceptor = plot(ax, NaN, NaN, '-','Linewidth',2,'Color',obj.ConcColors(2,:));
            obj.lhComplex= plot(ax, NaN, NaN, '-','Linewidth',2,'Color',obj.ConcColors(3,:));
            hold(ax,'off');
            lh = legend(ax,{'Drug','Receptor','Complex'},'FontName',obj.FontName);
            lh.Box = 'off';

            ax.XLimitMethod = "padded";
            ax.YLimitMethod = "padded";
        
            % instantiate listener
            dataListener = event.listener( model, 'DataChanged', ...
                @obj.update );
            
            % store listeners
            obj.DataListener = dataListener;
            
            % save objects
            obj.Model = model;
            obj.Axes = ax;
            
        end % constructor
        
   
    end % public methods
    
    methods ( Access = private )
        
        function update(obj,~,~)
            t = obj.Model.SimDataTable;

            set(obj.lhDrug,'XData',t.Time, 'YData',t.Drug);
            set(obj.lhReceptor,'XData',t.Time, 'YData',t.Receptor);
            set(obj.lhComplex,'XData',t.Time, 'YData',t.Complex);
            
        end % update

    end % private method
end % class

