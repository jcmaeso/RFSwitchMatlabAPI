classdef RFSwitch
    %RFSWITCH Control API for the 8 port RF Switch
    %   Detailed explanation goes here

    properties
        serialPort
        baudrate
    end

    methods
        % Init Method
        function obj = RFSwitch(portName)
            %RFSWITCH Construct an instance of this class
            %   Detailed explanation goes here
            obj.baudrate = 9600;
            obj.serialPort = serialport(portName,obj.baudrate);
            configureTerminator(obj.serialPort,"CRLF")
        end
        function [] = setRFChannel(obj,channel)
            %METHOD1 Change RF path (channel = 1-8) or turn off all RF channels (channel = 0)
            if numel(channel) ~= 1
                throw(MException('setRFChannel:invalidChannel','Channel value must be scalar',channel))
            end
            %Prevent Matlab shitty conversion
            channel_p  = cast(channel,"int8");
            if channel_p < 0 || channel_p > 8
                throw(MException('setRFChannel:invalidChannel','Channel %d is not valid, must be 1 to 8',channel))
            end
            write(obj.serialPort,string(channel_p),"string");
            rsp_txt = readline(obj.serialPort);
            %Communication management
            if startsWith(rsp_txt,"Invalid")
                throw(MException('setRFChannel:operationError','Switch rsp: "%s"',rsp_txt))
            elseif rsp_txt == "All pins OFF"
                disp(rsp_txt)
                % Read end command
                rsp_txt = readline(obj.serialPort);
            end
            if rsp_txt ~= "Action OK"
                throw(MException('setRFChannel:operationError','Communication Error'))
            end
        end
        % Deconstructor to close connection
        function delete(obj)
           delete(obj.serialPort); 
           disp("Connection Closed");
        end 
    end
end

