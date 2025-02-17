import React, { useRef, useState, useEffect } from 'react'
import Modal from 'react-modal';

import { PhoneInput } from 'react-international-phone';
import "primereact/resources/primereact.css";
import "primereact/resources/themes/saga-blue/theme.css";

import { useForm, Controller } from 'react-hook-form'
import { yupResolver } from  "@hookform/resolvers/yup";
import  *  as yup from  "yup";

import Input from "./Input";
import Button from './Button';
import CustomSelect from './Select';
import courses from '../utils/courses';

const validationSchema = yup.object().shape({
    name: yup.string().required('O nome é obrigatório'),
    lastName: yup.string().required('O sobrenome é obrigatório'),
    email: yup.string()
        .email('Email inválido')
        .test('unifesp-domain', 'O email deve ser do domínio @unifesp.br', function(value) {
        if (value) {
          return value.endsWith('@unifesp.br');
        }
        return true;
      })
      .required('O email é obrigatório'),
    birth: yup.date().required('A data de nascimento é obrigatória'),
    gender: yup.string().required('O gênero é obrigatório'),
    cpf: yup.string().matches(/^\d{3}\.\d{3}\.\d{3}-\d{2}$/, 'CPF inválido').required('O CPF é obrigatório'),
    rg: yup.string().required('O RG é obrigatório'),
    phone: yup.string().required('O telefone é obrigatório'),
    campus: yup.string().required('A unidade é obrigatória'),
    type: yup.string().required('O tipo de formação é obrigatório'),
    course: yup.string().required('O curso é obrigatório'),
    admissionYear: yup.string().required('O ano de ingresso é obrigatório'),
    graduationYear: yup.string().required('O ano de egresso é obrigatório'),
});
const errorClasses = 'text-red-600 text-center font-semibold mb-2';

const campis = [
    { value: 'Baixada Santista', label: 'Baixada Santista' },
    { value: 'Diadema', label: 'Diadema' },
    { value: 'Guarulhos', label: 'Guarulhos' },
    { value: 'Osasco', label: 'Osasco' },
    { value: 'São José dos Campos', label: 'São José dos Campos' },
    { value: 'São Paulo', label: 'São Paulo' },
    { value: 'Zona Leste', label: 'Zona Leste' }
]

const degreeTypes = [
    { value: 'Graduação', label: 'Graduação' },
    { value: 'Pós Graduação', label: 'Pós Graduação' }
]

const genders = [
    { value: 'Male', label: 'Masculino' },
    { value: 'Female', label: 'Feminino' }
]

export default function Registration({ contactData }) {
    const [showModal, setShowModal] = useState(false);

    const { register, setValue, handleSubmit, reset, control, formState: { errors } } = useForm({
        resolver: yupResolver(validationSchema),
    });
    const formRef = useRef<HTMLFormElement | null>(null);
    
    const customStyles = {
        content: {
            top: '50%',
            left: '50%',
            right: 'auto',
            bottom: 'auto',
            marginRight: '-50%',
            transform: 'translate(-50%, -50%)',
            backgroundColor: 'rgb(22 101 52)', 
            color: '#ffffff', 
            borderRadius: '10px', 
            width: '80%', 
            height: '80%', 
            maxWidth: '400px', 
            maxHeight: '200px', 
            boxShadow: '0 0 10px rgba(0, 0, 0, 0.2)', 
        },
    };

    useEffect(() => {
        if (contactData) {
            const parsedData = JSON.parse(contactData);
            // Preenche os campos do formulário com os dados do contato
            setValue('name', parsedData.name || '');
            setValue('lastName', parsedData.lastName || '');
            setValue('email', parsedData.email || '');
            setValue('birth', parsedData.birthdate || '');
            setValue('cpf', parsedData.cpf || '');
            setValue('rg', parsedData.rg || '');
            setValue('phone', parsedData.phone || '');
            setValue('gender', parsedData.gender || '');
        }
    }, [contactData, setValue]);

    function refreshPage() {
        window.location.reload();
    }

    const onSubmit = async (data) => {
        //localStorage.setItem('alumniData', JSON.stringify(data));
        try {
            const response = await fetch('http://localhost:3001/api', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({ data: data })
            });
      
            const result = await response.json();
            console.log(result.message);

            console.log(data);

            setShowModal(true);

          } catch (error) {
            console.error('Erro ao enviar os dados:', error);
          }

    };

   
    return(
        <div>
            <div className="bg-green-800 h-full flex items-center justify-center">
                <div className="bg-green-900 w-2/5 h-4/5 p-8 rounded-md mt-8 mb-8">
                    <form ref={formRef} onSubmit = { handleSubmit(onSubmit) } >
                        <h1 className="text-white text-4xl font-semibold mb-4 underline text-center">Cadastro</h1>
                        <Input register={register} id="name" label="Nome" type="text" required={true}/>
                        <p className={errorClasses}>{errors.name?.message}</p>
                        
                        <Input register={register} id="lastName" label="Sobrenome" type="text" required={true}/>
                        <p className={errorClasses}>{errors.lastName?.message}</p>
                        
                        <Input register={register} id="email" label="E-mail Institucional" type="email" required={true}/>
                        <p className={errorClasses}>{errors.email?.message}</p>
                        
                        <Input register={register} id="birth" label="Data de Nascimento" type="date" required={true}/>
                        <p className={errorClasses}>{errors.birth?.message == 'birth must be a `date` type, but the final value was: `Invalid Date` (cast from the value `""`).' ? 
                        'A data de nascimento é obrigatória': errors.birth?.message}</p>
                        
                        <Controller
                            name="gender"
                            control={control}
                            render={({ field }) => (
                            <CustomSelect
                                label='Gênero'
                                instanceId='unity'
                                options={genders}
                                onChange={(selectedOption) => field.onChange(selectedOption)}
                                value={field.value}
                            />
                            )}
                        />
                        <p className={errorClasses}>{errors.gender?.message}</p>
                        
                        <Input register={register} id="cpf" label="CPF" type="text" mask='CPF' required={true}/>
                        <p className={errorClasses}>{errors.cpf?.message}</p>
                        
                        <Input register={register} id="rg" label="RG" type="text" mask='RG' required={true}/>
                        <p className={errorClasses}>{errors.rg?.message}</p>
                        
                        <div className="flex flex-col justify-center items-center">
                            <label className='text-white'>
                                Telefone
                            </label>
                            <div className='mb-4 mt-0.5'>
                                <Controller
                                    name="phone"
                                    control={control}
                                    render={({ field }) => (
                                    <PhoneInput
                                        {...field}
                                        defaultCountry="br"
                                        inputStyle={{
                                            width: '100%',
                                            height: '2.25rem',
                                            border: '1px solid #CBD5E0',
                                            borderRadius: '0.375rem',
                                            paddingLeft: '0.75rem',
                                            paddingRight: '0.75rem',
                                            fontSize: '1rem',
                                            backgroundColor: '#FFFFFF',
                                            outline: 'none',
                                            transition: 'border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out',
                                          }}
                                      />
                                    )}
                                />
                            </div>
                        </div>

                        
                        <h1 className="text-white text-xl font-semibold mb-4 underline text-center">Qual foi a sua última formação na UNIFESP?</h1>
                        <Controller
                            name="campus"
                            control={control}
                            render={({ field }) => (
                            <CustomSelect
                                label='Unidade'
                                instanceId='unity'
                                options={campis}
                                onChange={(selectedOption) => field.onChange(selectedOption)}
                                value={field.value}
                            />
                            )}
                        />
                        <p className={errorClasses}>{errors.campus?.message}</p>
                        
                        <Controller
                            name="type"
                            control={control}
                            render={({ field }) => (
                            <CustomSelect
                                label='Tipo'
                                instanceId='type'
                                options={degreeTypes}
                                onChange={(selectedOption) => field.onChange(selectedOption)}
                                value={field.value}
                            />
                            )}
                        />
                        <p className={errorClasses}>{errors.type?.message}</p>
                                    <Controller
                                        name="course"
                                        control={control}
                                        render={({ field }) => (
                                        <CustomSelect
                                            label='Curso'
                                            instanceId='course'
                                            options={courses}
                                            onChange={(selectedOption) => field.onChange(selectedOption)}
                                            value={field.value}
                                        />
                                        )}
                                    />
                        <p className={errorClasses}>{errors.course?.message}</p> 

                        <Input register={register} id="admissionYear" label="Ano de Ingresso" type="text" required={true}/>
                        <p className={errorClasses}>{errors.admissionYear?.message}</p>

                        <Input register={register} id="graduationYear" label="Ano de Egresso" type="text" required={true}/>
                        <p className={errorClasses}>{errors.graduationYear?.message}</p>
                        
                        <div>
                            <div className='flex flex-col justify-center items-center mb-4'>
                                <div className='flex items-center justify-center mb-4 mt-0.5'>
                                    <Button 
                                        type="submit"
                                        className='absolute mt-12 px-4 py-2 rounded-xl bg-emerald-600 font-semibold text-white shadow-lg'
                                    >
                                        Cadastrar-se
                                    </Button>
                                </div>
                            </div>
                        </div>
                    </form>
                    <Modal
                        isOpen={showModal}
                        onRequestClose={() => setShowModal(false)}
                        style={customStyles}
                        contentLabel="Confirmação"
                    >
                         <div className="flex flex-col items-center justify-center h-full">
                            <h2 className="font-bold text-lg">Confirmação</h2>
                            <p className="mt-8 font-semibold text-lg">Dados enviados com sucesso!</p>
                            <button
                                onClick={refreshPage}
                                className="bg-green-900 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg mt-10 w-40"
                            >
                                Fechar
                            </button>
                        </div>
                    </Modal>
                </div>
            </div>
        </div>    
    )
}