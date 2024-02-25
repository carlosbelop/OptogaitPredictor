import joblib
import pandas as pd

def optoPredict(sample):
  ###Aplico todo el preprocesamiento realizado a los datos antes de entrenar el modelo:
  
  #Normalizo y estandarizo
  scaler=joblib.load('scaler.pkl')
  sample_scaled=scaler.transform(sample)
  
  #Cargo y aplico PCA
  pca = joblib.load('pca.pkl')
  sample_pca = pca.transform(sample_scaled)
  
  #Cargo el modelo
  model = joblib.load('modelo_entrenado.pkl')

  #Predigo
  return (model.predict(sample_pca.reshape(1,-1)))

pred1=pd.read_csv("pred1.csv", sep=";", header=0, decimal=',')
pred1=pred1.drop(['Unnamed: 0', 'ApellidosyNombre'],axis=1)
pred1=pred1.rename(columns={"Ritmo.paso.m..media":"Ritmopaso.media","Ritmo.paso.m..desviacion":"Ritmopaso.desviacion"})
print(optoPredict(pred1))