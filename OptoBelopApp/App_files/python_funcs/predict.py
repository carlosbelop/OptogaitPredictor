import joblib
import pandas as pd

def optoPredict(sample):
  ###Aplico todo el preprocesamiento realizado a los datos antes de entrenar el modelo:
  
  #Cargo el reductor de variables
  REF = joblib.load('./python_funcs/models/REF.pkl')
  sample_reduced=sample[REF.get_feature_names_out()]
  
  #Cargo el estandarizador y lo aplico
  scaler=joblib.load('./python_funcs/models/scaler.pkl')
  sample_scaled=scaler.transform(sample_reduced)
  
  #Cargo el modelo
  model = joblib.load('./python_funcs/models/modelo_entrenado.pkl')

  #Predigo
  return (model.predict_proba(sample_scaled.reshape(1,-1)))
