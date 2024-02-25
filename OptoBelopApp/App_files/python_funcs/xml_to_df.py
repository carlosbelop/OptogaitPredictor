import re
import pandas as pd
from io import StringIO
from unidecode import unidecode

def xml_to_df(file_path):
    #encoding="utf-8-sig" because the file is in UTF-8 with BOM
    with open(file_path, 'r', encoding="utf-8-sig") as fp:
        # read all text without written accents
        text = unidecode(fp.read())

    text=re.sub(r'</?Cell>[\n]','',text)
    #Splitting into lines
    lines= text.splitlines()

    # Removing first 12 lines
    lines = [line for i, line in enumerate(lines, start=1) if i not in range(0,13)]
    #Creating the final variable with the final text needed
    csv = ""
    firstrow=True #So there is not a new line in the first row
    columnnumber=1
    for line in lines:
        #new column
        if not re.search("<Row>",line):
            firstrow=False 
            #if there is a index in a column, it means the previous ones are empty
            if re.search("Index=",line):
                #take the index to write empty cells in a for
                tocolumn=int(re.findall(r'"([^"]*)"',line)[0])
                #write as many ";" as empty cells are between these two values
                csv+=";"*(tocolumn-columnnumber)
                columnnumber=tocolumn-1
            #create a cell with its respective information
            if re.search("Data",line):
                line=re.sub(r'<.*?>', '', line)
                csv+=line+";"
            columnnumber+=1
        #new row
        else:
            columnnumber=1
            if not firstrow:
                csv+="\n"
    #delete spaces
    csv=re.sub(r'[ \t\r\f\v]','',csv)
    #return dataframe
    df = pd.read_csv(StringIO(csv),delimiter=";")

    ####-----------------PROCESAMIENTO DEL DF PARA SU POSTERIOR PREDICCIÓN
    
    #Creo la columna nombre y apellidos
    ApellidosyNombre = df['Apellidos'][0] + df['Nombre'][0]
    df = df.drop(['Apellidos','Nombre','Nombreyapellidos','FechaDeNacimiento','Sexo',
    'Peso','Altura','Pie','Patologia','Nivel','Unidad','Empleo','ID','Escuela','Pectoral',
    'Freq.CardiacaMaxima','Freq.Cardiacaenreposo','FCanaerobicaMax','AlturaGyko','Test','Fecha',
    'Hora','#','L/R','Externo','TReaccion','TEspera','TVuelo','Elevacion','Potencia',
    'Split','AnguloDePaso','WalkingPointX','WalkingPointGapX','StepWidth','WalkingBase','PCI','HRM',
    'WalkingPointY','WalkingPointGapY','BodySwayAP','BodySwayML','NormalizedStep','TreadmillSpeed','TreadmillElevation',
    'TVueloPerc','Notas','Unnamed: 78','FCanaerobicaMax.1','Ritmo[p/s]'
    
    ], axis=1)
    #seguir procesando (media, desviacion...)
    
    #Getting the mean of all columns and transforming the Series class result to a new dataframe (with to_frame() and transpose())
    df_mean=df.mean().add_suffix(".media").to_frame().transpose()
    df_mean['ApellidosyNombre']=ApellidosyNombre
    df_deviation = df.std().add_suffix(".desviacion").to_frame().transpose()
    df_deviation['ApellidosyNombre']=ApellidosyNombre
    #final df
    
    df_fus=pd.merge(df_mean,df_deviation,on="ApellidosyNombre")

    #Change the column names so they are the same as in the trained model that we cleaned with R (R df colum names cannot have "%" "[]" "/" "\").
    #optimal thing would be doing the preprocess of the data with which we have trained the model in python too (but it's more time spent since I've alredy donde it in R)
    nuevos_nombres = [re.sub(r'\%|\\|\[|\]|\/', '.', col) for col in df_fus.columns]
    df_fus = df_fus.rename(columns=dict(zip(df_fus.columns, nuevos_nombres)))
    #deleting the name column and change an specific column name so they coincide
    df_fus=df_fus.drop(['ApellidosyNombre'], axis=1)
    df_fus=df_fus.rename(columns={"Ritmo.paso.m..media":"Ritmo.paso.media","Ritmo.paso.m..desviacion":"Ritmo.paso.desviacion"})
    
    weight = pd.DataFrame({'Peso.Kg.': [''],
                   'Altura.cm.': [''],
                   'N.Pie': ['']
                   })
    df_fus=pd.concat([weight, df_fus], axis=1)
    
    return(df_fus)




