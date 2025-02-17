import React, { useRef, useState } from 'react'
import Input from "./Input";
import Button from './Button';

import { useForm, Controller } from 'react-hook-form'
import { yupResolver } from  "@hookform/resolvers/yup";
import  *  as yup from  "yup";

const validationSchema = yup.object().shape({
    cpf: yup
      .string()
      .matches(/^\d{3}\.\d{3}\.\d{3}-\d{2}$/, 'CPF inválido')
      .required('O CPF é obrigatório'),
});

const errorClasses = 'text-red-600 text-center font-semibold mb-2';

type FormValues = {
    cpf: string;
};

export default function Search({ onSearchComplete  }) {
    const { register, handleSubmit, reset, formState: { errors }} = useForm<FormValues>({
        resolver: yupResolver(validationSchema),
    });

    const onSearch = async (data) => {
        try {
          const response = await fetch(`http://localhost:3001/api/contact?cpf=${encodeURIComponent(data.cpf)}`, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
            },
          });
    
          const result = await response.json();
    
          if (response.ok) {
            console.log('Dados encontrados:', result.data);
            onSearchComplete(result.data);
          } else {
            console.error('Erro ao buscar contato:', result.error);
            alert(`Aluno não encontrado! Por favor, realize o cadastro.`);
            onSearchComplete(null);
          }
        } catch (error) {
          console.error('Erro ao realizar a busca:', error);
          alert('Ocorreu um erro na comunicação com o servidor.');
        }
      };

    return (
        <div>
            <div className="bg-green-800 h-full flex items-center justify-center">
                <div className="bg-green-900 w-2/5 h-4/5 p-8 rounded-md mt-8 mb-8">
                    <h1 className="text-white text-4xl font-semibold mb-4 underline text-center">Informe seu CPF</h1>
                    
                    {/* Formulário com onSubmit */}
                    <form onSubmit={handleSubmit(onSearch)}>
                        <Input register={register} id="cpf" label="CPF" type="text" mask="CPF" required={true} />
                        <p className={errorClasses}>{errors.cpf?.message}</p>

                        <div>
                        <div className="flex flex-col justify-center items-center mb-4">
                            <div className="flex items-center justify-center mb-4 mt-0.5">
                            <Button
                                type="submit"
                                className="absolute mt-12 px-4 py-2 rounded-xl bg-emerald-600 font-semibold text-white shadow-lg"
                            >
                                Buscar
                            </Button>
                            </div>
                        </div>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    )
}