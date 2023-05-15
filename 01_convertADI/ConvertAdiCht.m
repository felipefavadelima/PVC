%Convert ADI files to mat
clear all
folder = uigetdir(pwd,'adicht data folder');
files = getAllFiles(folder);
Outfolder = uigetdir(pwd,'Outfolder');
for nfile = 1:length(files)
    filename = files{nfile};
    [filepath,name,ext] = fileparts(filename);
    if strcmp(ext,'.adicht')
        adif = adi.readFile(filename);
        disp('#######################################');
        disp([name '.adicht'])
        disp(['n_records ' num2str(adif.n_records)]);
        disp(['n_channels ' num2str(adif.n_channels)]);
        for nrec =1:adif.n_records
            disp(['REC_' num2str(nrec) ' ' ...
                adif.records(nrec).data_start_str ' '...
                num2str(adif.records(nrec).tick_fs) ' Hz ' ...
                num2str(adif.records(nrec).duration/60) 'min'])
        end
        if(adif.n_channels ~= 4)
            error('Nchannels Problem...');
        end
        if(adif.n_records>1)
            warning('Nrecords greater than 1')
            Ans = input('Wich records to save ? (Ex: 1,2   or 1) ',"s");
            eval(['records2process = [' Ans '];']);
        else
            records2process = [1];
        end
        SubId = strsplit(name,'_');
        SubId = SubId{1};
        for nrec = records2process
            rectime_str = datestr(adif.records(nrec).data_start);
            rectime = adif.records(nrec).data_start;
            timeStr = datestr(rectime_str,'yyyymmdd_HHMM');
            matFileName = [SubId '_' timeStr '.mat'];
            Ch1Data = adif.getChannelData(1,nrec);
            Ch2Data = adif.getChannelData(2,nrec);
            Ch3Data = adif.getChannelData(3,nrec);
            Ch4Data = adif.getChannelData(4,nrec);
            ChDatas = [Ch1Data Ch2Data Ch3Data Ch4Data];
            if(adif.records(nrec).tick_fs > 200)
                warning(['Fs ' num2str(adif.records(nrec).tick_fs) ' Hz. Data resampled to 200Hz.'])
                ChDatas = resample(ChDatas,200,adif.records(nrec).tick_fs);
            end
            if(adif.records(nrec).tick_fs < 200)
                error('Fs error.')
            end
            ChFs_Hz = 200;
            ProcessSteps = {'adicht2mat'};
            save([Outfolder '\' matFileName],"ChDatas","ChDatas",...
                "SubId","rectime_str","rectime","ChFs_Hz","ProcessSteps");
        end

    end
end