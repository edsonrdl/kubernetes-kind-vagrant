#!/bin/bash

echo "🚀 Criando carga artificial para aumentar a CPU..."
kubectl run stress-test --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://minha-app-service; done" &

# Aguarda 1 minuto (60 segundos) para gerar carga
sleep 60

echo "🛑 Removendo carga artificial para verificar redução automática..."
kubectl delete pod stress-test

echo "✅ Teste concluído! Verifique o comportamento do HPA com:"
echo "kubectl get hpa -w"

