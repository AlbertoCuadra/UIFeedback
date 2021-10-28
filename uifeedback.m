classdef uifeedback < matlab.apps.AppBase
    %      Author: Alberto  Cuadra Lara
    %     Website: acuadralara.com
    % Last update: 28/10/2021
    
    % Properties that correspond to app components
    properties (Access = public)
        feedbackUIFigure  matlab.ui.Figure
        attachments       matlab.ui.control.TextArea
        ClearButton       matlab.ui.control.Button
        subject           matlab.ui.control.DropDown
        AttachButton      matlab.ui.control.Button
        SendButton        matlab.ui.control.Button
        name              matlab.ui.control.EditField
        email             matlab.ui.control.EditField
        message           matlab.ui.control.TextArea
    end

    
    properties (Access = private)
        attachFiles       % attachment file
        FLAG_SEND = false % FLAG mail send
        subject_0         % Default subject
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Take snapshot
%             gui_SnapshotMenuSelected(app.feedbackUIFigure);
            % Default subject
            app.subject_0 = app.subject.Value;
        end

        % Button pushed function: SendButton
        function SendButtonPushed(app, event)
            % Inputs
            source = 'sourceMail@gmail.com';   % source email address (gmail)
            sourcePassword = 'sourcePassword'; % source password
            recipients = 'recipients';         % recipient email address (any email). Use {'mail1','mail2',...} for a set of recipients 
            subj = app.subject.Value;          % subject mail
            name = app.name.Value;             % name of the sender (for contact)
            mail = app.email.Value;            % email of the sender (for contact)
            msg = app.message.Value;           % main body of email
            attch = app.attachFiles;           % attachments
            % Set up SMTP service for gmail
            setpref('Internet', 'E_mail', source);
            setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
            setpref('Internet', 'SMTP_Username', source);
            setpref('Internet', 'SMTP_Password', sourcePassword);
            % Gmail server
            props = java.lang.System.getProperties;
            props.setProperty('mail.smtp.auth', 'true');
            props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port', '465');
            % Format message
            msg = [{strcat('Name: ', name)}; {strcat('Email: ', mail)}; {' '}; msg];
            % Send the email
            if ~isempty(mail) && contains(mail, '@') && contains(mail, '.')
                if ~app.FLAG_SEND
                    if ~isempty(msg{4})
                        try
                            if isempty(attch)
                                sendmail(recipients, subj, msg);         
                            else
                                sendmail(recipients, subj, msg, attch)
                            end
                            app.FLAG_SEND = true;
                            uialert(app.feedbackUIFigure, 'Message sent', 'Info', 'Icon', 'success');
                        catch
                            app.FLAG_SEND = false;
                        end
                    else
                        uialert(app.feedbackUIFigure, 'Empty message', 'Warning', 'Icon', 'warning');
                    end
                else
                    uialert(app.feedbackUIFigure, 'Message already sent', 'Info', 'Icon', 'info');
                end
            else
                uialert(app.feedbackUIFigure, 'Empty email', 'Warning', 'Icon', 'warning');
            end
        end

        % Button pushed function: AttachButton
        function AttachButtonPushed(app, event)
            [file, path] = uigetfile({'*.png';'*.jpg';'*.svg';'*.pdf';'*.m'}, 'Select One or More Files', 'MultiSelect', 'on');
            if ~isnumeric(file)
                try
                    app.attachments.Value = {file};
                catch
                    app.attachments.Value = file;
                end
                app.attachFiles = strcat(path, file);
            end
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            % Clear GUI
            app.subject.Value = app.subject_0;
            app.name.Value = '';
            app.email.Value = '';
            app.message.Value = '';
            app.attachments.Value = '';
            app.attachFiles = 0;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create feedbackUIFigure and hide until all components are created
            app.feedbackUIFigure = uifigure('Visible', 'off');
            app.feedbackUIFigure.AutoResizeChildren = 'off';
            app.feedbackUIFigure.Color = [0.9098 0.9098 0.8902];
            app.feedbackUIFigure.Position = [650 300 425 349];
            app.feedbackUIFigure.Name = 'Feedback';
            app.feedbackUIFigure.Icon = 'feedback_icon.png';
            app.feedbackUIFigure.Resize = 'off';

            % Create message
            app.message = uitextarea(app.feedbackUIFigure);
            app.message.Placeholder = 'message';
            app.message.Position = [11 9 405 223];

            % Create email
            app.email = uieditfield(app.feedbackUIFigure, 'text');
            app.email.Placeholder = 'email';
            app.email.Position = [11 242 231 25];

            % Create name
            app.name = uieditfield(app.feedbackUIFigure, 'text');
            app.name.Placeholder = 'name (optional)';
            app.name.Position = [11 277 231 25];

            % Create SendButton
            app.SendButton = uibutton(app.feedbackUIFigure, 'push');
            app.SendButton.ButtonPushedFcn = createCallbackFcn(app, @SendButtonPushed, true);
            app.SendButton.Icon = 'send_icon.svg';
            app.SendButton.Position = [255 312 75 25];
            app.SendButton.Text = 'Send';

            % Create AttachButton
            app.AttachButton = uibutton(app.feedbackUIFigure, 'push');
            app.AttachButton.ButtonPushedFcn = createCallbackFcn(app, @AttachButtonPushed, true);
            app.AttachButton.Icon = 'clip_icon.svg';
            app.AttachButton.Position = [341 312 75 25];
            app.AttachButton.Text = 'Attach';

            % Create subject
            app.subject = uidropdown(app.feedbackUIFigure);
            app.subject.Items = {'bug', 'enhancement', 'documentation'};
            app.subject.Editable = 'on';
            app.subject.BackgroundColor = [1 1 1];
            app.subject.Placeholder = 'subject';
            app.subject.Position = [11 312 142 25];
            app.subject.Value = 'bug';

            % Create ClearButton
            app.ClearButton = uibutton(app.feedbackUIFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Icon = 'clear_icon.svg';
            app.ClearButton.Position = [167 312 75 25];
            app.ClearButton.Text = 'Clear';

            % Create attachments
            app.attachments = uitextarea(app.feedbackUIFigure);
            app.attachments.Editable = 'off';
            app.attachments.Position = [255 242 161 60];

            % Show the figure after all components are created
            app.feedbackUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = uifeedback

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.feedbackUIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.feedbackUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.feedbackUIFigure)
        end
    end
end