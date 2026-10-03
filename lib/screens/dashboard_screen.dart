import 'package:flutter/material.dart';
import 'package:chamada_ufam/models/usuario_model.dart';
import 'package:chamada_ufam/models/sessao_chamada_model.dart';
import 'package:chamada_ufam/services/session_service.dart';
import 'package:chamada_ufam/services/sessao_chamada_service.dart';
import 'package:chamada_ufam/screens/login_screen.dart';
import 'package:chamada_ufam/services/presenca_service.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _sessaoService = SessaoChamadaService();
  late Future<List<SessaoChamada>> _futureSessoes;

  @override
  void initState() {
    super.initState();
    _carregarSessoes();
  }

  void _carregarSessoes() {
    setState(() {
      _futureSessoes = _sessaoService.listarSessoesAtivas(widget.usuario.token);
    });
  }

  void _fazerLogout(BuildContext context) async {
    await SessionService().clearSession();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _mostrarDialogoPresenca(SessaoChamada sessao) {
    final pinController = TextEditingController();
    bool enviando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Registar Presença: ${sessao.disciplina}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Insira o PIN fornecido pelo professor:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'PIN de Acesso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: enviando ? null : () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
                ElevatedButton(
                  onPressed: enviando
                      ? null
                      : () async {
                          setDialogState(() => enviando = true);
                          try {
                            await PresencaService().registrarPresenca(
                              sessao.id,
                              pinController.text,
                              widget.usuario.token,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Presença registada com sucesso!'),
                                  backgroundColor: Color(0xFF006633),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              if (e.toString().contains('SESSAO_EXPIRADA')) {
                                Navigator.pop(context);
                                _fazerLogout(context);
                                return;
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => enviando = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006633),
                    foregroundColor: Colors.white,
                  ),
                  child: enviando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CONFIRMAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UFAM - Painel Principal'),
        backgroundColor: const Color(0xFF006633),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregarSessoes,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () => _fazerLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF006633),
                  child: Text(
                    widget.usuario.nome.isNotEmpty ? widget.usuario.nome[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  widget.usuario.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${widget.usuario.tipo} • Matrícula: ${widget.usuario.matricula}'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.usuario.tipo == 'PROFESSOR' ? 'Sessões de Chamada Criadas' : 'Chamadas Disponíveis',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<SessaoChamada>>(
                future: _futureSessoes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final erro = snapshot.error.toString();
                    
                    if (erro.contains('SESSAO_EXPIRADA')) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _fazerLogout(context));
                      return const Center(child: Text('Sessão expirada. A sair...'));
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text('Erro: ${erro.replaceAll('Exception: ', '')}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _carregarSessoes,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma sessão de chamada ativa no momento.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final sessoes = snapshot.data!;
                  return ListView.builder(
                    itemCount: sessoes.length,
                    itemBuilder: (context, index) {
                      final sessao = sessoes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.class_, color: Color(0xFF006633), size: 36),
                          title: Text(
                            sessao.disciplina,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Prof: ${sessao.professorNome}\nInício: ${sessao.dataHoraInicio.hour}:${sessao.dataHoraInicio.minute.toString().padLeft(2, '0')}'),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () {
                              if (widget.usuario.tipo == 'PROFESSOR') {
                                // Futuro: Abrir ecrã com a lista de alunos presentes
                              } else {
                                _mostrarDialogoPresenca(sessao);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006633),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(widget.usuario.tipo == 'PROFESSOR' ? 'VER' : 'REGISTAR'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}