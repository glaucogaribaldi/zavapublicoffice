# Model Strategy — NVIDIA / Nemotron

## Requirements

- Prefer NVIDIA/Nemotron models.
- Keep application logic model-agnostic.
- Support current GCloud VPS and future Mac mini M4 16 GB.
- Benchmark before selecting a production model.

## Current VPS

Known hardware:

```text
n1-highmem-16
16 vCPU
104 GB RAM
500 GB HDD
NVIDIA Tesla P4 8 GB
```

Treat all software/runtime state as unknown until audited.

## Runtime evaluation order

1. verify `nvidia-smi` and driver;
2. verify CUDA compatibility;
3. benchmark storage and RAM;
4. build/install llama.cpp with CUDA support if viable;
5. expose an OpenAI-compatible local endpoint;
6. test candidate Nemotron GGUF models;
7. record prompt processing and generation tok/s, RAM, VRAM, context and stability.

## FULL profile

Goal: heavy historical reconstruction and batch work.

Candidate family: Nemotron 3 Nano, selecting a quantization/size that is actually usable on the P4 + system RAM.

Do not hard-code a specific 30B candidate until benchmark passes.

If large model performance is unacceptable, use a smaller local Nemotron for continuous work and reserve heavy tasks for scheduled/batch execution or a later GPU node.

## EDGE profile

Final target:

```text
Mac mini M4
16 GB unified memory
256 GB SSD
network access available
```

EDGE must not need to rebuild the archive from raw sources.

Expected EDGE responsibilities:
- retrieve structured memory;
- answer questions;
- process small numbers of new messages/files;
- update entities/timeline/open loops incrementally;
- run compact local model(s).

Keep large raw storage and optionally canonical services network-accessible if beneficial.

## One visible model, multiple internal workers

Giacomo speaks only to TRE. Internally TRE may route tasks to:
- main reasoning LLM;
- compact extraction LLM;
- embeddings model;
- deterministic parsers.

This complexity must remain invisible in normal use.

## Structured outputs

Extraction prompts should use constrained JSON/schema outputs where possible. Validate before persistence.

Never let free-form LLM text directly mutate canonical facts without validation/provenance.

## Benchmark record

Create `runtime/benchmarks/` and record:
- date;
- git/runtime version;
- model ID/file;
- quantization;
- context;
- CPU threads;
- GPU layers/offload;
- RAM/VRAM;
- prompt tok/s;
- generation tok/s;
- test prompt;
- stability notes.

## Portability rule

The rest of Ufficio Zava calls a provider interface, not a model filename. Changing model must be configuration, not a rewrite.
