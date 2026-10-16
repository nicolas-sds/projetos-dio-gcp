# Terraform: Hierarquia e Governança GCP - Mercado Central

Resolução do desafio da DIO para organização de pastas, projetos e grupos de acesso (IAM) no Google Cloud Platform.

---

## Diagrama

![Diagrama da Arquitetura](diagramas/arquitetura.png)

```text
mercado-central
│
├── Operacoes
│   └── Caixa-PDV
│       ├── Desenvolvimento ──> prj-pdv-dev
│       └── Producao        ──> prj-pdv-prod
│
└── Administrativo
    └── Financeiro
        ├── Desenvolvimento ──> prj-fin-dev
        └── Producao        ──> prj-fin-prod
```
## Grupos de Acesso
- *Desenvolvedores*: `roles/editor` apenas nas pastas de `Desenvolvimento`.
- *Operações / Suporte*: `roles/viewer` nas pastas de `Producao`.
