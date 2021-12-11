unit VisioUtils;

interface

uses Classes,Variants,ActiveX, ComObj,
      ResourceUtils, MainUtils;
type

TVisioConverter = Class(TDocumentConverter)
Private
    FVSVersion : String;
    VisioApp : OleVariant;

public
             constructor Create();
    function CreateOfficeApp() : boolean;  override;
    function DestroyOfficeApp() : boolean; override;
    function ExecuteConversion(fileToConvert: String; OutputFilename: String; OutputFileFormat : Integer): TConversionInfo; override;
    function AvailableFormats() : TStringList; override;
    function FormatsExtensions(): TStringList; override;
    function OfficeAppVersion() : String; override;
End;

implementation

{ TVisioConverter }

function TVisioConverter.AvailableFormats: TStringList;
begin
  Formats := TResourceStrings.Create('VSFORMATS');
  result := Formats;
end;

constructor TVisioConverter.Create;
begin
inherited;
    //setup defaults
  InputExtension := '.vsd*';
  OfficeAppName := 'Visio';
end;

function TVisioConverter.CreateOfficeApp: boolean;
begin
  if  VarIsEmpty(VisioApp) then
  begin
    VisioApp :=  CreateOleObject('Visio.Application');
    VisioApp.Visible := false;

  end;
  Result := true;
end;

function TVisioConverter.DestroyOfficeApp: boolean;
begin
  if not VarIsEmpty(VisioApp) then
  begin
    VisioApp.Quit;
  end;
  Result := true;
end;

function TVisioConverter.ExecuteConversion(
                          fileToConvert,
                          OutputFilename: String;
                          OutputFileFormat: Integer): TConversionInfo;
var
ActiveVisioDoc : OleVariant;
begin
        Result.Successful := false;
        Result.InputFile := fileToConvert;
        // Open file
        ActiveVisioDoc := VisioApp.Documents.Open(fileToConvert);

        // Save as file and close
        if OutputFileFormat = 5000 then
        begin
              ActiveVisioDoc.ExportAsFixedFormat(1,OutputFileName,0,0);
        end else if OutputFileFormat = 5001 then
        begin
              ActiveVisioDoc.ExportAsFixedFormat(2,OutputFileName,0,0);
        end;

//               ActiveVisioDoc.SaveAs(OutputFileName, OutputFileFormat, false);
  //      ActiveVisioDoc.Save;

        ActiveVisioDoc.Close;

        Result.InputFile := fileToConvert;
        Result.Successful := true;
        Result.OutputFile := OutputFilename;
end;

function TVisioConverter.FormatsExtensions: TStringList;
begin

end;

function TVisioConverter.OfficeAppVersion: String;
begin
  FVSVersion := ReadOfficeAppVersion;
  if FVSVersion = '' then
  begin
  CreateOfficeApp();
  FVSVersion := VisioApp.Version;
  WriteOfficeAppVersion(FVSVersion);
  end;
  result := FVSVersion;
end;

end.
